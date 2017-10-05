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

    def managers
      Person.with_roles(self, Role::GROUP_ADMIN)
    end

    has_many :scores, as: :scoreable

    scope :permitted, ->(uuids) { where(id: uuids) }

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
        self.root_comments.each{|comment| comment.destroy}
      end
  end
end
