require 'buzzn/score_calculator'

module Group
  class Base < ActiveRecord::Base
    self.table_name = :groups
    resourcify
    acts_as_commentable
    include Filterable

    HYBRID = 'hybrid'
    CHP = 'chp'
    PV = 'pv'

    before_save do
      self.slug = Buzzn::Slug.new(self.name)
    end

    before_destroy :destroy_content

    def meters
      Meter::Base.where(
        Register::Base.where('registers.group_id = ? and registers.meter_id = meters.id', self)
          .select(1)
          .exists
        )
    end

    validates :name, presence: true, uniqueness: true, length: { in: 4..40 }

    mount_uploader :logo, PictureUploader
    #mount_uploader :image, PictureUploader

    has_many :registers, class_name: Register::Base, foreign_key: :group_id

    has_many :brokers, class_name: Broker::Base, as: :resource, :dependent => :destroy

    #has_many :managers, -> { where roles:  { name: 'manager'} }, through: :roles, source: :users
    def managers
      User.users_of(self, :manager)
    end

    has_many :scores, as: :scoreable

    normalize_attributes :description, :website

    scope :restricted, ->(uuids) { where(id: uuids) }


    def self.search_attributes
      [:name, :description]
    end

    def self.filter(search)
      do_filter(search, *search_attributes)
    end

    def input_registers
      registers.input
    end


    def output_registers
      registers.output
    end

    def calculate_total_energy_data(data, operators, resolution)
      calculate_virtual_register(data, operators, resolution)
    end



    def energy_generator_type
      all_labels = output_registers.collect(&:label).uniq
      if all_labels.include?(Register::Base::PRODUCTION_CHP) && all_labels.include?(Register::Base::PRODUCTION_PV)
        return HYBRID
      elsif all_labels.include?(Register::Base::PRODUCTION_CHP)
        return CHP
      elsif all_labels.include?(Register::Base::PRODUCTION_PV)
        return PV
      end
    end

    def self.score_interval(resolution_format, containing_timestamp)
      if resolution_format == 'year_to_minutes' || resolution_format == 'year'
        return ['year', Time.at(containing_timestamp).in_time_zone.beginning_of_year, Time.at(containing_timestamp).in_time_zone.end_of_year]
      elsif resolution_format == 'month_to_minutes' || resolution_format == 'month'
        return ['month', Time.at(containing_timestamp).in_time_zone.beginning_of_month, Time.at(containing_timestamp).in_time_zone.end_of_month]
      elsif resolution_format == 'day_to_minutes' || resolution_format == 'day'
        return ['day', Time.at(containing_timestamp).in_time_zone.beginning_of_day, Time.at(containing_timestamp).in_time_zone.end_of_day]
      end
    end

    def set_score_interval(resolution_format, containing_timestamp)
      self.class.score_interval(resolution_format, containing_timestamp)
    end
    alias :get_score_interval :set_score_interval
    alias :score_interval :set_score_interval

    def extrapolate_kwh_pa(kwh_ago, resolution_format, containing_timestamp)
      days_ago = 0
      if resolution_format == 'year'
        if Time.at(containing_timestamp).end_of_year < Time.current
          days_ago = 365
        else
          days_ago = ((Time.current - Time.current.beginning_of_year)/(3600*24.0)).to_i
        end
      elsif resolution_format == 'month'
        if Time.at(containing_timestamp).end_of_month < Time.current
          days_ago = Time.at(containing_timestamp).days_in_month
        else
          days_ago = Time.current.day
        end
      elsif resolution_format == 'day'
        if Time.at(containing_timestamp).in_time_zone.end_of_day < Time.current
          days_ago = 1
        else
          days_ago = (Time.current - Time.current.beginning_of_day)/(3600*24.0)
        end
      end
      return kwh_ago / (days_ago*1.0) * 365
    end

    def self.calculate_scores
      Sidekiq::Client.push({
       'class' => CalculateGroupScoresWorker,
       'queue' => :default,
       'args' => [ (Time.current - 1.day).to_i ]
      })
    end

    def calculate_scores(containing_timestamp)
      Buzzn::ScoreCalculator.new(self, containing_timestamp).calculate_all_scores
    end

    def finalize_registers
      # TODO: check data source if other organization than discovergy
      if self.registers.size < 3
        return false
      end
      #TODO ideally the discovergy_data_source gets passed in from outside here
      data_source = Buzzn::Application.config.data_source_registry.get(:discovergy)
      brokers = data_source.create_virtual_meters_for_group(self)
      if brokers.any?
        return true
      end
      return false
    end

    private

      def destroy_content
        self.registers.each do |register|
          register.group = nil
          register.save
        end
        self.root_comments.each{|comment| comment.destroy}
      end
  end
end
