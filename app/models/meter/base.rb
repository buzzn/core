# coding: utf-8
module Meter
  class Base < ActiveRecord::Base
    self.table_name = :meters
    resourcify
    include Filterable

    # TODO
    # TODO need to figure which attributes belongs to real
    # TODO and which attributes belong to virtual and
    # TODO adjust it, i.e. move the constants and add 'validates'
    # TODO declarations
    # TODO

    # voltage levels
    LOW_LEVEL = 'E06' # low_level
    MID_LEVEL = 'E05' # mid_level
    HIGH_LEVEL = 'E04' # high_level
    HIGHEST_LEVEL = 'E03' # highest_level
    VOLTAGE_LEVELS = [LOW_LEVEL, MID_LEVEL, HIGH_LEVEL, HIGHEST_LEVEL]

    # cycle intervals
    MONTHLY = 'MONTHLY'
    YEARLY = 'YEARLY'
    QUARTERLY = 'QUARTERLY'
    HALF_YEARLY = 'HALF_YEARLY'
    CYCLE_INTERVALS = [MONTHLY, YEARLY, QUARTERLY, HALF_YEARLY]

    # metering type
    ANALOG_HOUSEHOLD_METER = 'AHZ' # analog_household_meter
    LOAD_METER = 'LAZ' # load_meter - Lastgangzähler
    ANALOG_AC_METER = 'WSZ' # analog_ac_meter - Wechselstromzähler
    DIGITAL_HOUSEHOLD_METER = 'EHZ' # digital_household_meter
    MAXIMUM_METER = 'MAZ' # maximum_meter
    INDIVIDUAL_ADJUSTMENT = 'IVA' # individual_adjustment
    METERING_TYPES = [ANALOG_HOUSEHOLD_METER, LOAD_METER,
                      ANALOG_AC_METER, DIGITAL_HOUSEHOLD_METER, MAXIMUM_METER,
                      INDIVIDUAL_ADJUSTMENT]

    # meter sizes
    EDL40 = 'Z01' # edl40
    EDL21 = 'Z02' # edl21
    OTHER_EHZ = 'Z03' # other_ehz
    METER_SIZES = [EDL40, EDL21, OTHER_EHZ]

    # tariffs
    ONE_TARIFF = 'ETZ' # single tariff
    TWO_TARIFFS = 'ZTZ' # dual tariffs
    MULTIPLE_TARIFFS = 'NTZ' # multi tariffs
    TARIFFS = [ONE_TARIFF, TWO_TARIFFS, MULTIPLE_TARIFFS]

    # data loggings
    REMOTE = 'AMR' # remote
    MANUAL = 'MMR' # manual
    DATA_LOGGINGS = [REMOTE, MANUAL]
    MEASUREMENT_METHODS = [REMOTE, MANUAL]

    # mounting methods
    PLUG_TECHNIQUE = 'BKE' # plug_technique
    THREE_POINT_HANGING = 'DPA' # three point mounting
    CAP_RAIL = 'HS' # cap_rail - Hutschiene
    MOUNTING_METHODS = [PLUG_TECHNIQUE, THREE_POINT_HANGING, CAP_RAIL]

    # ownerships
    BUZZN_SYSTEMS = 'BUZZN_SYSTEMS'
    FOREIGN_OWNERSHIP = 'FOREIGN_OWNERSHIP'
    CUSTOMER = 'CUSTOMER'
    LEASED = 'LEASED'
    BOUGHT = 'BOUGHT'
    OWNERSHIPS = [BUZZN_SYSTEMS, FOREIGN_OWNERSHIP, CUSTOMER, LEASED, BOUGHT]

    # direction numbers
    ONE_WAY_METER = 'ERZ' # one_way_meter
    TWO_WAY_METER = 'ZRZ' # two_way_meter
    DIRECTION_NUMBERS = [ONE_WAY_METER, TWO_WAY_METER]

    # sections
    ELECTRICITY = 'S'
    GAS = 'G'
    SECTIONS = [ELECTRICITY, GAS]

    has_one :broker, as: :resource, dependent: :destroy, foreign_key: :resource_id, class_name: 'Broker::Base'
    validates_associated :broker

    # hack for restricted scope
    has_many :registers, class_name: Register::Base, foreign_key: :meter_id

    validates :build_year, presence: false
    validates :calibrated_until, presence: false
    validates :edifact_measurement_method, presence: false
    validates :edifact_voltage_level, inclusion: {in: VOLTAGE_LEVELS}, if: 'edifact_voltage_level.present?'
    validates :edifact_cycle_interval, inclusion: {in: CYCLE_INTERVALS}, if: 'edifact_cycle_interval.present?'
    validates :edifact_metering_type, inclusion: {in: METERING_TYPES}, if: 'edifact_metering_type.present?'
    validates :edifact_meter_size, inclusion: {in: METER_SIZES}, if: 'edifact_meter_size.present?'
    validates :edifact_tariff, inclusion: {in: TARIFFS}, if: 'edifact_tariff.present?'
    validates :edifact_data_logging, inclusion: {in: DATA_LOGGINGS}, if: 'edifact_data_logging.present?'
    validates :edifact_measurement_method, inclusion: {in: MEASUREMENT_METHODS}, if: 'edifact_measurement_method.present?'
    validates :edifact_mounting_method, inclusion: {in: MOUNTING_METHODS}, if: 'edifact_mounting_method.present?'
    validates :ownership, inclusion: {in: OWNERSHIPS}, if: 'ownership.present?'
    validates :edifact_section, inclusion: {in: SECTIONS}, if: 'edifact_section.present?'

    validate :validate_invariants

    def validate_invariants
    end

    scope :reals,      -> {where(type: Real)}
    scope :virtuals,   -> {where(type: Virtual)}    
    scope :restricted, ->(uuids) { joins(registers: :contracts).where('contracts.id': uuids) }

    def name
      "#{manufacturer_name} #{product_serialnumber}"
    end

    def self.search_attributes
      [:manufacturer_name, :product_name, :product_serialnumber]
    end

    def self.filter(value)
      do_filter(value, *search_attributes)
    end
  end
end
