require 'buzzn/slug'

module Group
  class Base < ActiveRecord::Base

    self.table_name = :groups
    include Filterable

    HYBRID = 'hybrid'
    CHP = 'chp'
    PV = 'pv'

    before_save :check_slug
    before_create :check_slug

    before_destroy :destroy_content

    belongs_to :address
    belongs_to :bank_account

    has_many :meters, class_name: 'Meter::Base', foreign_key: :group_id
    has_many :registers, class_name: 'Register::Base', through: :meters
    has_many :register_meta, class_name: 'Register::Meta', through: :registers, foreign_key: :register_meta_id, source: :meta

    def managers
      Person.with_roles(self, Role::GROUP_ADMIN)
    end

    def mentors
      Person.with_roles(self, Role::GROUP_ENERGY_MENTOR)
    end

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

    private

      def destroy_content
        self.registers.each do |register|
          register.group = nil
          register.save
        end
      end

      def check_slug
        if self.slug.nil?
          baseslug = Buzzn::Slug.new(self.name)

          self.slug = baseslug

          count = Slug.get_next('organization', baseslug)
          if count.positive? || self.class.where(:slug => self.slug)
            self.slug = Buzzn::Slug.new(self.name, count)
          end
          Slug.commit('organization', baseslug, self.slug)
        end
      end

  end
end
