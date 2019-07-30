module Meter
  class Base < ActiveRecord::Base

    self.table_name = :meters
    include Filterable

    belongs_to :group, class_name: 'Group::Base'
    belongs_to :address
    belongs_to :broker, class_name: 'Broker::Base'

    has_many :registers, class_name: 'Register::Base', foreign_key: :meter_id

    before_destroy do
      # TODO need to figure out what to do with the sequence_number
      raise 'can not delete meter with group' if group
    end

    before_save { maybe_create_sequence_number }

    scope :real,      -> {where(type: Real)}
    scope :virtual,   -> {where(type: Virtual)}
    scope :real_or_virtual, -> {where(type: [Real, Virtual])}
    scope :restricted, ->(uids) { joins(registers: { market_location: :contracts}).where('contracts.id': uids) }

    def name
      "#{manufacturer_name} #{product_serialnumber}"
    end

    def self.search_attributes
      [:product_name, :product_serialnumber]
    end

    def self.filter(value)
      do_filter(value, *search_attributes)
    end

    def datasource
      broker ? :discovergy : :standard_profile
    end

    private

    def maybe_create_sequence_number
      if group_id_changed?
        raise ArgumentError.new('can not change group') unless group_id_was.nil?
        unless sequence_number
          max = Meter::Base.where(group: group).maximum(:sequence_number)
          self.sequence_number = max.to_i + 1
        end
      end
    end

  end
end
