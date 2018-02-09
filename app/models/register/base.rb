# frozen-string-literal: true
require_relative '../filterable'

module Register
  class Base < ActiveRecord::Base
    self.table_name = :registers

    include Import.active_record['services.current_power']

    include Filterable

    class Label < String
      ['production', 'consumption', 'demarcation', 'grid'].each do |method|
        define_method "#{method}?" do
          self.to_s.start_with?(method)
        end
      end
    end

    enum label: %i(consumption consumption_common
      demarcation_pv demarcation_chp demarcation_wind demarcation_water
      production_pv production_chp production_wind production_water
      grid_consumption grid_feeding
      grid_consumption_corrected grid_feeding_corrected
      other
    ).each_with_object({}) { |item, map| map[Label.new(item.to_s)] = item.to_s.upcase }

    enum direction: { input: 'in', output: 'out' }

    has_many :contracts, class_name: 'Contract::Base', dependent: :destroy, foreign_key: 'register_id'
    has_many :devices, foreign_key: 'register_id'
    has_many :readings, class_name: 'Reading::Single', foreign_key: 'register_id'

    scope :real,    -> { where(type: [Register::Input, Register::Output]) }
    scope :virtual, -> { where(type: Register::Virtual) }

    scope :consumption_production, -> do
      by_labels(*Register::Base.labels.select { |label, _| label.production? || label.consumption? }.values)
    end

    scope :production_consumption, -> do
      consumption_production
    end

    scope :production, -> do
      by_labels(*Register::Base.labels.select { |label, _| label.production? }.values)
    end

    scope :by_group, -> (group) do
      group ? self.where(group: group.id) : self.where(group: nil)
    end

    scope :by_labels, -> (*labels) do
      if (Register::Base.labels.values & labels).sort != labels.sort
        raise ArgumentError.new("#{labels.inspect} needs to be subset of #{Register::Base.labels.values}")
      end
      self.where('label in (?)', labels)
    end

    # permissions helpers

    scope :permitted, ->(uuids) { joins(:contracts).where('contracts.id': uuids) }

    def self.search_attributes
      [:name]
    end

    def self.filter(value)
      do_filter(value, *search_attributes)
    end


    def data_source
      Buzzn::MissingDataSource.name
    end

    def broker
      meter.broker
    end

    # FIXME: it would be best to raise an exception here (and even define this class as abstract as well)
    # but raising here causes lots of test & code to fail.
    def obis
      nil
    end

    def low_load_ability
      false
    end

    def pre_decimal_position
      6
    end

    def post_decimal_position
      1
    end

    # not used anymore
    def calculate_forecast
      readings = readings.user_input
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



    # TODO move me into clockwork
    def self.observe
      Sidekiq::Client.push(
        'class' => RegisterObserveWorker,
        'queue' => :default,
        'args' => []
      )
    end

    def self.create_all_observer_activities
      where('observer_enabled = ? OR observer_offline_monitoring = ?', true, true).each do |register|
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

      if Time.new.to_i - last_reading.timestamp.to_i >= 5.minutes
        if observer_offline_monitoring
          if Time.new.to_i - last_reading.timestamp.to_i < 10.minutes
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

    def direction?(val)
      case val.to_s.downcase.sub(/put/, '').to_sym
      when :in
        input?
      when :out
        output?
      else
        raise "unknown direction #{val}"
      end
    end
  end
end
