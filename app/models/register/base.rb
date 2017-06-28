module Register
  class Base < ActiveRecord::Base
    self.table_name = :registers
    resourcify

    include Import.active_record['service.current_power', 'service.charts']

    include Filterable

    #label constants
    CONSUMPTION = 'consumption'
    DEMARCATION_PV = 'demarcation_pv'
    DEMARCATION_CHP = 'demarcation_chp'
    PRODUCTION_PV = 'production_pv'
    PRODUCTION_CHP = 'production_chp'
    GRID_CONSUMPTION = 'grid_consumption'
    GRID_FEEDING = 'grid_feeding'
    GRID_CONSUMPTION_CORRECTED = 'grid_consumption_corrected'
    GRID_FEEDING_CORRECTED = 'grid_feeding_corrected'
    OTHER = 'other'

    class << self
      def labels
        @label ||= [CONSUMPTION, DEMARCATION_PV, DEMARCATION_CHP, PRODUCTION_PV, PRODUCTION_CHP,
                    GRID_CONSUMPTION, GRID_FEEDING, GRID_CONSUMPTION_CORRECTED, GRID_FEEDING_CORRECTED, OTHER]
      end
    end

    belongs_to :group, class_name: Group::Base, foreign_key: :group_id


    has_many :contracts, class_name: Contract::Base, dependent: :destroy, foreign_key: 'register_id'
    has_many :devices, foreign_key: 'register_id'
    has_one :address, as: :addressable, dependent: :destroy

    has_many :scores, as: :scoreable

    def data_source
      Buzzn::MissingDataSource.name
    end

    def brokers
      Broker::Base.where(resource_id: self.meter.id, resource_type: Meter::Base)
    end

    def self.directions; %w(in out); end

    validates :meter, presence: true
    validates :metering_point_id, uniqueness: false, length: { in: 4..34 }, allow_blank: true
    validates :name, presence: true, length: { in: 2..40 }
    # TODO virtual register ?
    validates :image, presence: false
    validates :regular_reeding, presence: false
    validates :observer_enabled, presence: false
    validates :observer_min_threshold, presence: false
    validates :observer_max_threshold, presence: false
    validates :last_observed, presence: false
    # TODO virtual register ?
    validates :observer_offline_monitoring, presence: false
    validates :label, inclusion: { in: labels }

    validate :validate_invariants

    mount_uploader :image, PictureUploader

    before_destroy :destroy_content

    # permissions helpers

    scope :restricted, ->(uuids) { joins(:contracts).where('contracts.id': uuids) }

    scope :inputs,   -> { where(direction: 'in') }
    scope :outputs,  -> { where(direction: 'out') }
    scope :reals,    -> { where(type: [Register::Input, Register::Output]) }
    scope :virtuals, -> { where(type: Register::Virtual) }

    scope :consumption_production, -> do
      by_label(Register::Base::CONSUMPTION,
               Register::Base::PRODUCTION_PV,
               Register::Base::PRODUCTION_CHP)
    end

    scope :by_group, lambda {|group|
      group ? self.where(group: group.id) : self.where(group: nil)
    }

    scope :by_label, lambda {|*labels|
      labels.each do |label|
        raise ArgumentError.new('Undefined constant "' + label + '". Only use constants defined by Register::Base.labels.') unless self.labels.include?(label)
      end
      self.where("label in (?)", labels)
    }

    def self.search_attributes
      [:name, address: [:city, :state, :street_name]]
    end

    def self.filter(value)
      do_filter(value, *search_attributes)
    end

    def validate_invariants
      if contracts.size > 0 && address.nil?
        errors.add(:address, 'missing Address when having contracts')
      end
      if observer_max_threshold < observer_min_threshold
        errors.add(:observer_max_threshold, 'must be greater or equal min_watt')
        errors.add(:observer_min_threshold, 'must be smaller or equal max_watt')
      end
    end

    def readings
      @_readings ||= Reading.all_by_register_id(self.id)
    end

    def output?
      self.direction == 'out'
    end

    def input?
      self.direction == 'in'
    end

    def calculate_forecast
      if smart?
        return
      end
      readings = Reading.all_by_register_id_and_source(self.id, 'user_input')
      if readings.size > 1
        last_timestamp = readings.last[:timestamp].to_i
        last_value = readings.last[:energy_milliwatt_hour]/1000000.0
        another_timestamp = readings[readings.size - 2][:timestamp].to_i
        another_value = readings[readings.size - 2][:energy_milliwatt_hour]/1000000.0
        i = 3
        while last_timestamp - another_timestamp < 2592000 do # difference must at least be 30 days = 2592000 seconds
          if i > readings.size
            return
          end
          another_timestamp = readings[readings.size - i][:timestamp].to_i
          another_value = readings[readings.size - i][:energy_milliwatt_hour]/1000000.0
          i += 1
        end
        if last_timestamp - another_timestamp >= 2592000
          count_days_in_year = (Time.at(last_timestamp).end_of_year - Time.at(last_timestamp).beginning_of_year)/(3600*24)
          count_past_days = ((Time.at(last_timestamp) - Time.at(another_timestamp))/3600/24).to_i
          count_watt_hour = last_value - another_value
          yearly_consumption = (count_watt_hour / (count_past_days * 1.0)) * count_days_in_year

          self.forecast_kwh_pa = yearly_consumption
          self.save
        end

      end
    end



    def self.observe
      Sidekiq::Client.push({
         'class' => RegisterObserveWorker,
         'queue' => :default,
         'args' => []
        })
    end


    def self.calculate_scores
      Register::Base.all.select(:id, :direction).each.each do |register|
        if register.input?
          Sidekiq::Client.push({
           'class' => CalculateRegisterScoreSufficiencyWorker,
           'queue' => :default,
           'args' => [ register.id, 'day', Time.current.to_i*1000]
          })

          Sidekiq::Client.push({
           'class' => CalculateRegisterScoreFittingWorker,
           'queue' => :default,
           'args' => [ register.id, 'day', Time.current.to_i*1000]
          })
        end
      end
    end

    def self.create_all_observer_activities
      where("observer_enabled = ? OR observer_offline_monitoring = ?", true, true).each do |register|
        register.create_observer_activities rescue nil
      end
    end

    UNDERSHOOTS = :undershoots
    EXCEEDS     = :exceeds
    OFFLINE     = :offline
    NONE        = :none

    def create_observer_activities
      if (last_reading = current_power.for_register(self)).nil?
        return NONE
      end

      # last readings are in milliwatt
      power = last_reading.value / 1000.0

      if Time.current.utc.to_i - last_reading.timestamp.to_i >= 5.minutes
        if observer_offline_monitoring
          puts 'here'
          if Time.current.utc.to_i - last_reading.timestamp.to_i < 10.minutes
            OFFLINE
          else
            NONE
          end
        end
      elsif observer_enabled
        update(last_observed: Time.at(last_reading.timestamp/1000.0).utc)
        if power < observer_min_threshold && power >= 0
          UNDERSHOOTS
        elsif power >= observer_max_threshold
          EXCEEDS
        else
          NONE
        end
      else
        NONE
      end
    end

    private

    def destroy_content
      # TODO use delete_all ?
      self.root_comments.each{|comment| comment.destroy}
    end
  end
end
