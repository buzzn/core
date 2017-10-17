# frozen-string-literal: true
module Reading
  class Single < ActiveRecord::Base

    self.table_name = :readings

    # reason constants
    DEVICE_SETUP = 'IOM'
    DEVICE_CHANGE_1 = 'COM1'
    DEVICE_CHANGE_2 = 'COM2'
    DEVICE_REMOVAL = 'ROM'
    REGULAR_READING = 'PMR' #Turnusablesung
    MIDWAY_READING = 'COT' #Zwischenablesung
    CONTRACT_CHANGE = 'COS'
    DEVICE_PARAMETER_CHANGE = 'CMP'
    BALANCING_ZONE_CHANGE = 'COB'
    enum reason: {
           device_setup: DEVICE_SETUP,
           device_change_1: DEVICE_CHANGE_1,
           device_change_2: DEVICE_CHANGE_2,
           device_removal: DEVICE_REMOVAL,
           regular_reading: REGULAR_READING,
           midway_reading: MIDWAY_READING,
           contract_change: CONTRACT_CHANGE,
           device_parameter_change: DEVICE_PARAMETER_CHANGE,
           balancing_zone_change: BALANCING_ZONE_CHANGE,
         }
    REASONS = [DEVICE_SETUP, DEVICE_CHANGE_1, DEVICE_CHANGE_2, DEVICE_REMOVAL,
               REGULAR_READING, MIDWAY_READING, CONTRACT_CHANGE,
               DEVICE_PARAMETER_CHANGE, BALANCING_ZONE_CHANGE].freeze

    # quality constants
    UNUSABLE = '20'
    SUBSTITUE_VALUE = '67'
    ENERGY_QUANTITY_SUMMARIZED = '79'
    FORECAST_VALUE = '187'
    READ_OUT = '220' # abgelesen
    PROPOSED_VALUE = '201'
    enum quality: {
           unusable: UNUSABLE,
           substitude_value: SUBSTITUE_VALUE,
           energy_quantity_summarized: ENERGY_QUANTITY_SUMMARIZED,
           forecast_value: FORECAST_VALUE,
           read_out: READ_OUT,
           proposed_Value: PROPOSED_VALUE,
         }
    QUALITIES = [UNUSABLE, SUBSTITUE_VALUE, ENERGY_QUANTITY_SUMMARIZED, FORECAST_VALUE, READ_OUT, PROPOSED_VALUE].freeze

    # source constants
    SMART = 'SM'
    MANUAL = 'MAN'
    enum source: {
           smart: SMART,
           manual: MANUAL
         }
    SOURCES = [SMART, MANUAL].freeze

    # status
    Z86 = 'Z86'
    Z84 = 'Z84'
    Z83 = 'Z83'
    enum status: {
           z83: Z83,
           z84: Z84,
           z86: Z86
         }
    STATUS = [Z83, Z84, Z86].freeze

    # read_by
    BUZZN = 'BN'
    POWER_TAKER = 'SN'
    POWER_GIVER = 'SG'
    DISTRIBUTION_SYSTEM_OPERATOR = 'VNB'
    enum read_by: {
           buzzn: BUZZN,
           power_taker: POWER_TAKER,
           power_giver: POWER_GIVER,
           distribution_system_operator: DISTRIBUTION_SYSTEM_OPERATOR
         }
    READ_BY_VALUES = [BUZZN, POWER_TAKER, POWER_GIVER,
                      DISTRIBUTION_SYSTEM_OPERATOR ].freeze

    # units
    WH = 'Wh'
    W = 'W'
    M3 = 'm³'
    enum unit: {
           watt_hour: WH,
           watt: W,
           cubic_meter: M3
         }
    UNITS = [WH, W, M3].freeze

    belongs_to :register, class_name: Register::Base


    scope :in_year, -> (year) {
      where('date >= ? AND date < ?', Date.new(year), Date.new(year + 1))
    }

    scope :between, ->(begin_date, end_date) {
      where('date >= ? AND date < ?', begin_date, end_date)
    }

    scope :with_reason, lambda {|*reasons|
      where(reason: reasons)
    }

    scope :without_reason, lambda {|*reasons|
      where('reason NOT IN (?)', reasons)
    }

    validate :validate_invariants

    def validate_invariants
      if manual? && watt_hour?
        # TODO value_has_to_grow
      end
    end

    def value_has_to_grow
      readings = register.readings.manual.order(:date)
      reading_before = readings.where('date < ?', date).last
      reading_after = readings.where('date > ?', date).first
      if !reading_before.nil? && reading_before.value > value
        self.errors.add(:value, "is lower than the last one: #{reading_before.value}")
      end
      if !reading_after.nil? && reading_after.value < value
        self.errors.add(:value, "is greater than the next one: #{reading_after.value}")
      end
    end

    def corrected_value
      Buzzn::Utils::Number.send(unit, value)
    end

    def corrected_value=(val)
      self.unit = val.unit
      self.value = val.value
    end
  end
end
