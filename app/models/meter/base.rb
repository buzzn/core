# coding: utf-8
module Meter
  class Base < ActiveRecord::Base
    self.table_name = :meters
    resourcify
    include Filterable

    # VoltageLevel
    LOW_LEVEL = 'low_level'
    MID_LEVEL = 'mid_level'
    HIGH_LEVEL = 'high_level'
    HIGHEST_LEVEL = 'highest_level'

    # CycleInterval
    MONTHLY = 'monthly'
    YEARLY = 'yearly'
    QUARTERLY = 'quarterly'
    HALF_YEARLY = 'half_yearly'

    # MeteringType
    ANALOG_HOUSEHOLD_METER = 'analog_household_meter'
    SMART_METER = 'smart_meter'
    LOAD_METER = 'load_meter' # Lastgangzähler
    ANALOG_AC_METER = 'analog_ac_meter' # Wechselstromzähler
    DIGITAL_HOUSEHOLD_METER = 'digital_household_meter'
    MAXIMUM_METER = 'maximum_meter'
    INDIVIDUAL_ADJUSTMENT = 'individual_adjustment'

    # MeterSize
    EDL40 = 'edl40'
    EDL21 = 'edl21'
    OTHER_EHZ = 'other_ehz'

    # Tariff
    ONE_TARIFF = 'one_tariff'
    TWO_TARIFFS = 'two_tariffs'
    MULTIPLE_TARIFFS = 'multiple_tariffs'

    # DataLogging
    REMOTE = 'remote'
    MANUAL = 'manual'

    # MountingMethod
    PLUG_TECHNIQUE = 'plug_technique'
    THREE_POINT_HANGING = 'three_point_hanging'
    CAP_RAIL = 'cap_rail' # Hutschiene

    # ownership
    BUZZN_SYSTEMS = 'buzzn_systems'
    FOREIGN_OWNERSHIP = 'foreign_ownership'
    CUSTOMER = 'customer'
    LEASED = 'leased'
    BOUGHT = 'bought'

    # direction
    ONE_WAY_METER = 'one_way_meter'
    TWO_WAY_METER = 'two_way_meter'


    class << self
      def all_voltage_levels
        @voltage_level ||= [LOW_LEVEL, MID_LEVEL, HIGH_LEVEL, HIGHEST_LEVEL]
      end

      def all_cycle_intervals
        @cycle_interval ||= [MONTHLY, YEARLY, QUARTERLY, HALF_YEARLY]
      end

      def all_metering_types
        @metering_type ||= [ANALOG_HOUSEHOLD_METER, SMART_METER, LOAD_METER, ANALOG_AC_METER,
                            DIGITAL_HOUSEHOLD_METER, MAXIMUM_METER, INDIVIDUAL_ADJUSTMENT]
      end

      def all_meter_sizes
        @meter_size ||= [EDL40, EDL21, OTHER_EHZ]
      end

      def all_tariffs
        @tariff ||= [ONE_TARIFF, TWO_TARIFFS, MULTIPLE_TARIFFS]
      end

      def all_data_loggings
        @data_logging ||= [REMOTE, MANUAL]
      end

      def all_mounting_methods
        @mounting_method ||= [PLUG_TECHNIQUE, THREE_POINT_HANGING, CAP_RAIL]
      end

      def all_ownerships
        @ownership ||= [BUZZN_SYSTEMS, FOREIGN_OWNERSHIP, CUSTOMER, LEASED, BOUGHT]
      end
    end

    has_one :broker, as: :resource, dependent: :destroy, foreign_key: :resource_id, class_name: 'Broker::Base'
    validates_associated :broker

    has_one :main_equipment, class_name: Meter::Equipment, foreign_key: 'meter_id'
    has_one :secondary_equipment, class_name: Meter::Equipment, foreign_key: 'meter_id'

    # hack for restricted scope
    has_many :registers, class_name: Register::Base, foreign_key: :meter_id

    validates :measurement_capture, presence: false
    validates :build_year, presence: false
    validates :calibrated_till, presence: false
    validates :init_first_reading, presence: false
    validates :init_reading, presence: false
    validates :voltage_level, inclusion: {in: all_voltage_levels}, if: 'voltage_level.present?'
    validates :cycle_interval, inclusion: {in: all_cycle_intervals}, if: 'cycle_interval.present?'
    validates :metering_type, inclusion: {in: all_metering_types}, if: 'metering_type.present?'
    validates :meter_size, inclusion: {in: all_meter_sizes}, if: 'meter_size.present?'
    validates :tariff, inclusion: {in: all_tariffs}, if: 'tariff.present?'
    validates :data_logging, inclusion: {in: all_data_loggings}, if: 'data_logging.present?'
    validates :mounting_method, inclusion: {in: all_mounting_methods}, if: 'mounting_method.present?'
    validates :ownership, inclusion: {in: all_ownerships}, if: 'ownership.present?'

    validate :validate_invariants

    after_create :create_main_equipment

    def validate_invariants
    end

    before_destroy do
      Meter::Equipment.where(meter_id: self.id).delete_all
    end

    scope :reals,      -> {where(type: Real)}
    scope :virtuals,   -> {where(type: Virtual)}    
    scope :restricted, ->(uuids) { joins(registers: :contracts).where('contracts.id': uuids) }

    def name
      "#{manufacturer_name} #{manufacturer_product_serialnumber}"
    end

    def self.search_attributes
      [:manufacturer_name, :manufacturer_product_name, :manufacturer_product_serialnumber]
    end

    def self.filter(value)
      do_filter(value, *search_attributes)
    end

    def create_main_equipment
      if main_equipment.nil?
        Meter::Equipment.create!(converter_constant: 1, meter: self, ownership: Meter::Equipment::BUZZN_SYSTEMS)
      end
    end
  end
end
