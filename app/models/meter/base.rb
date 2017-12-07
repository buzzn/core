module Meter
  class Base < ActiveRecord::Base
    self.table_name = :meters
    include Filterable

    belongs_to :group, class_name: 'Group::Base'
    belongs_to :address
    belongs_to :broker, class_name: 'Broker::Base'

    # needed for permitted scope
    has_many :registers, class_name: Register::Base, foreign_key: :meter_id

    before_save do
      # if group_id_changed?
        # raise ArgumentError.new('can not change group') unless group_id_was.nil? # Yes we can! For tests we want that
        unless sequence_number
          max = Meter::Base.where(group: group).size
          self.sequence_number = max
        end
      # end
    end

    before_destroy do
      # TODO need to figure out what to do with the sequence_number
      raise 'can not delete meter with group' if group
    end

    validates :build_year, presence: false
    validates :calibrated_until, presence: false
    validates :edifact_measurement_method, presence: false

    scope :real,      -> {where(type: Real)}
    scope :virtual,   -> {where(type: Virtual)}
    scope :restricted, ->(uuids) { joins(registers: :contracts).where('contracts.id': uuids) }

    def name
      "#{manufacturer_name} #{product_serialnumber}"
    end

    def self.search_attributes
      [:product_name, :product_serialnumber]
    end

    def self.filter(value)
      do_filter(value, *search_attributes)
    end
  end
end
