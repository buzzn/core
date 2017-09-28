# coding: utf-8
module Meter
  class Base < ActiveRecord::Base
    self.table_name = :meters
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
    enum edifact_voltage_level: {
           low_level:     LOW_LEVEL,
           mid_level:     MID_LEVEL,
           high_level:    HIGH_LEVEL,
           highest_level: HIGHEST_LEVEL,
         }
    VOLTAGE_LEVELS = [LOW_LEVEL, MID_LEVEL, HIGH_LEVEL, HIGHEST_LEVEL]

    # cycle intervals
    MONTHLY = 'MONTHLY'
    QUARTERLY = 'QUARTERLY'
    HALF_YEARLY = 'HALF_YEARLY'
    YEARLY = 'YEARLY'
    enum edifact_cycle_interval: {
           monthly:     MONTHLY,
           quarterly:   QUARTERLY,
           half_yearly: HALF_YEARLY,
           yearly:      YEARLY,
         }
    CYCLE_INTERVALS = [MONTHLY, YEARLY, QUARTERLY, HALF_YEARLY]

    # metering type
    ANALOG_HOUSEHOLD_METER = 'AHZ' # analog_household_meter
    ANALOG_AC_METER = 'WSZ' # analog_ac_meter - Wechselstromzähler
    LOAD_METER = 'LAZ' # load_meter - Lastgangzähler
    MAXIMUM_METER = 'MAZ' # maximum_meter
    DIGITAL_HOUSEHOLD_METER = 'EHZ' # digital_household_meter
    INDIVIDUAL_ADJUSTMENT = 'IVA' # individual_adjustment
    enum edifact_metering_type: {
           analog_household_meter:  ANALOG_HOUSEHOLD_METER ,
           analog_ac_meter:         ANALOG_AC_METER,
           load_meter:              LOAD_METER,
           maximum_meter:           MAXIMUM_METER,
           digital_household_meter: DIGITAL_HOUSEHOLD_METER,
           individual_adjustment:   INDIVIDUAL_ADJUSTMENT,
         }
    METERING_TYPES = [ANALOG_HOUSEHOLD_METER, LOAD_METER,
                      ANALOG_AC_METER, DIGITAL_HOUSEHOLD_METER, MAXIMUM_METER,
                      INDIVIDUAL_ADJUSTMENT]

    # meter sizes
    EDL40 = 'Z01' # edl40
    EDL21 = 'Z02' # edl21
    OTHER_EHZ = 'Z03' # other_ehz
    enum edifact_meter_size: {
           edl40: EDL40,
           edl21: EDL21,
           other_ehz: OTHER_EHZ,
         }
    METER_SIZES = [EDL40, EDL21, OTHER_EHZ]

    # tariffs
    SINGLE_TARIFF = 'ETZ' # single tariff
    DUAL_TARIFF = 'ZTZ' # dual tariffs
    MULTI_TARIFF = 'NTZ' # multi tariffs
    enum edifact_tariff: {
           single_tariff: SINGLE_TARIFF,
           dual_tariff:   DUAL_TARIFF,
           multi_tariff:  MULTI_TARIFF,
         }
    TARIFFS = [SINGLE_TARIFF, DUAL_TARIFF, MULTI_TARIFF]

    # data loggings
    ANALOG = 'Z04'
    ELECTRONIC = 'Z05'
    enum edifact_data_logging: {
           analog:     ANALOG,
           electronic: ELECTRONIC,
         }
    DATA_LOGGINGS = [ANALOG, ELECTRONIC]

    # measurement methods
    REMOTE = 'AMR'
    MANUAL = 'MMR'
    enum edifact_measurement_method: {
           remote: REMOTE,
           manual: MANUAL,
         }
    MEASUREMENT_METHODS = [REMOTE, MANUAL]

    # mounting methods
    PLUG_TECHNIQUE = 'BKE' # plug_technique
    THREE_POINT_MOUNTING = 'DPA' # three point mounting
    CAP_RAIL = 'HS' # cap_rail - Hutschiene
    enum edifact_mounting_method: {
           plug_technique:       PLUG_TECHNIQUE,
           three_point_mounting: THREE_POINT_MOUNTING,
           cap_rail:             CAP_RAIL,
         }
    MOUNTING_METHODS = [PLUG_TECHNIQUE, THREE_POINT_MOUNTING, CAP_RAIL]

    # ownerships
    BUZZN_SYSTEMS = 'BUZZN_SYSTEMS'
    FOREIGN_OWNERSHIP = 'FOREIGN_OWNERSHIP'
    CUSTOMER = 'CUSTOMER'
    LEASED = 'LEASED'
    BOUGHT = 'BOUGHT'
    enum ownership: {
           buzzn_systems:     BUZZN_SYSTEMS,
           foreign_ownership: FOREIGN_OWNERSHIP,
           customer:          CUSTOMER,
           leased:            LEASED,
           bought:            BOUGHT
         }
    OWNERSHIPS = [BUZZN_SYSTEMS, FOREIGN_OWNERSHIP, CUSTOMER, LEASED, BOUGHT]

    # sections
    ELECTRICITY = 'S'
    GAS = 'G'
    enum section: {
           electricity: ELECTRICITY,
           gas:         GAS
         }
    SECTIONS = [ELECTRICITY, GAS]

    has_one :broker, as: :resource, dependent: :destroy, foreign_key: :resource_id, class_name: 'Broker::Base'
    validates_associated :broker

    belongs_to :group, class_name: Group::Localpool

    # hack for restricted scope
    has_many :registers, class_name: Register::Base, foreign_key: :meter_id

    before_save do
      if group_id_changed?
        raise ArgumentError.new('can not change group') unless group_id_was.nil?
        max = Meter::Base.where(group: group).size
        self.position = max
      end
    end

    before_destroy do
      # TODO need to figure out the position thingy
      raise 'can not delete meter with group' if group
    end

    validates :build_year, presence: false
    validates :calibrated_until, presence: false
    validates :edifact_measurement_method, presence: false

    validate :validate_invariants

    def validate_invariants
    end

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
