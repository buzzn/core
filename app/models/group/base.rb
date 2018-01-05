require 'buzzn/score_calculator'

module Group
  class Base < ActiveRecord::Base
    self.table_name = :groups
    include Filterable

    HYBRID = 'hybrid'
    CHP = 'chp'
    PV = 'pv'

    before_save do
      self.slug = Buzzn::Slug.new(self.name)
    end

    before_destroy :destroy_content

    belongs_to :address
    belongs_to :bank_account

    has_many :meters, class_name: 'Meter::Base', foreign_key: :group_id
    has_many :registers, class_name: 'Register::Base', through: :meters

    def managers
      Person.with_roles(self, Role::GROUP_ADMIN)
    end

    def mentors
      Person.with_roles(self, Role::GROUP_ENERGY_MENTOR)
    end

    has_many :scores, as: :scoreable

    scope :permitted, ->(uuids) { where(id: uuids) }

    def self.search_attributes
      [:name, :description]
    end

    def self.filter(search)
      do_filter(search, *search_attributes)
    end

    def energy_generator_type
      # TODO with new labels in place this is outdated now
      all_labels = registers.output.collect(&:label).uniq
      if all_labels.include?(Register::Base.labels[:production_chp]) && all_labels.include?(Register::Base.labels[:production_pv])
        return HYBRID
      elsif all_labels.include?(Register::Base.labels[:production_chp])
        return CHP
      elsif all_labels.include?(Register::Base.labels[:production_pv])
        return PV
      end
    end

    def self.calculate_scores
      Sidekiq::Client.push({
       'class' => CalculateGroupScoresWorker,
       'queue' => :default,
       'args' => [ Buzzn::Utils::Chronos.yesterday.to_s ]
      })
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
      end
  end
end
