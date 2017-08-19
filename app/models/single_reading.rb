# frozen-string-literal: true
class SingleReading < ActiveRecord::Base

  # reason constants
  DEVICE_SETUP = 'device_setup'
  DEVICE_CHANGE_1 = 'device_change_1'
  DEVICE_CHANGE_2 = 'device_change_2'
  DEVICE_REMOVAL = 'device_removal'
  REGULAR_READING = 'regular_reading' #Turnusablesung
  MIDWAY_READING = 'midway_reading' #Zwischenablesung
  CONTRACT_CHANGE = 'contract_change'
  DEVICE_PARAMETER_CHANGE = 'device_parameter_change'
  BALANCING_ZONE_CHANGE = 'balancing_zone_change'
  OTHER_REASON = 'other'
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
         other_reason: OTHER_REASON
       }
  REASONS = [DEVICE_SETUP, DEVICE_CHANGE_1, DEVICE_CHANGE_2, DEVICE_REMOVAL,
             REGULAR_READING, MIDWAY_READING, CONTRACT_CHANGE,
             DEVICE_PARAMETER_CHANGE, BALANCING_ZONE_CHANGE,
             OTHER_REASON].freeze

  # quality constants
  UNUSABLE = 'unusable'
  SUBSTITUE_VALUE = 'substitue_value'
  ENERGY_QUANTITY_SUMMARIZED = 'energy_quantity_summarized'
  FORECAST_VALUE = 'forecast_value'
  READ_OUT = 'read_out' # abgelesen
  PROPOSED_VALUE = 'proposed_value'
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
  BUZZN_SYSTEMS = 'buzzn_systems'
  CUSTOMER_LSG = 'customer_lsg' #lsg = localpool strom geber
  LSN = 'lsn' # lsn = localpool strom nehmer
  VNB = 'vnb' # vnb = verteilnetzbetreiber
  THIRD_PARTY_MSB_MDL = 'third_party_msb_mdl' # msb = messstellenbetreiber, mdl = messdienstleister
  USER_INPUT = 'user_input'
  SLP = 'slp'
  SEP_PV = 'sep_pv'
  SEP_BHKW = 'sep_bhkw'
  OTHER_SOURCE = 'other'
  enum source: {
         buzzn_systems: BUZZN_SYSTEMS,
         customer_power_giver: CUSTOMER_LSG,
         localpool_power_taker: LSN,
         dso: VNB,
         third_party_msb_mdl: THIRD_PARTY_MSB_MDL,
         user_input: USER_INPUT,
         slp: SLP,
         sep_pv: SEP_PV,
         sep_bhkw: SEP_BHKW,
         other_source: OTHER_SOURCE
       }
  SOURCES = [BUZZN_SYSTEMS, CUSTOMER_LSG, LSN, VNB, THIRD_PARTY_MSB_MDL,
            USER_INPUT, SLP, SEP_PV, SEP_BHKW, OTHER_SOURCE].freeze

  # status
  Z86 = 'Z86'
  enum status: {
         z86: Z86
       }
  STATUS = [Z86].freeze

  # read_by
  VALUE = 'value'
  enum read_by: {
         value: VALUE
       }
  READ_BY_VALUES = [VALUE].freeze

  # units
  WH = 'Wh'
  W = 'W'
  M3 = 'm^3'
  enum unit: {
         watt_hour: WH,
         watt: W,
         cubic_meter: M3
       }
  UNITS = [WH, W, M3].freeze

  belongs_to :register, class_name: Register::Base

  #validates :reason, inclusion: { in: REASONS }
  #validates :quality, inclusion: { in: QUALITIES }
  #validates :source, inclusion: { in: SOURCES }
  #validates :register_id, presence: true
  #validates :timestamp, presence: true
  #validates_uniqueness_of :timestamp, scope: [:register_id, :reason], message: 'already available for given register and reason'

  scope :in_year, -> (year) {
    where('date >= ? AND date < ?', Date.new(year), Date.new(year + 1))
  }

  scope :between, ->(begin_date, end_date) {
    where('date >= ? AND date < ?', begin_date, end_date)
  }
  
  #scope :at, -> (date) do
  #   where(:timestamp.gte => timestamp).where(:timestamp.lt => timestamp + 1.second)
  # end

  scope :by_reason, lambda {|*reasons|
    where(reason: reasons)
  }

  scope :without_reason, lambda {|*reasons|
    where('reason NOT IN (?)', reasons)
  }

  validate :validate_invariants

  def validate_invariants
     if user_input? && watt_hour?
       value_has_to_grow
     end
  end

  def value_has_to_grow
    readings = register.readings.user_input.order(:timestamp).limit(1)
    reading_before = readings.where(:timestamp.lt => timestamp).last
    reading_after = readings.where(:timestamp.gt => timestamp).first
    if !reading_before.nil? && reading_before.value > value
      self.errors.add(:value, "is lower than the last one: #{reading_before.value}")
    end
    if !reading_after.nil? && reading_after.value < value
      self.errors.add(:value, "is greater than the next one: #{reading_after.value}")
    end
  end

  def corrected_value
    Buzzn::Math::Number.send(unit, value)
  end

  def corrected_value=(val)
    self.unit = val.unit
    self.value = val.value
  end
end
