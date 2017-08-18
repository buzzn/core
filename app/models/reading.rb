class Reading
  include Mongoid::Document

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
  OTHER = 'other' # also used four source

  # quality constants
  NOT_USABLE = 'not_usable'
  SUBSTITUE_VALUE = 'substitue_value'
  ENERGY_QUANTITY_SUMMARIZED = 'energy_quantity_summarized'
  FORECAST_VALUE = 'forecast_value'
  READ_OUT = 'read_out' # abgelesen
  PROPOSED_VALUE = 'proposed_value'

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

  class << self
    def reasons
      @reason ||= [DEVICE_SETUP, DEVICE_CHANGE_1, DEVICE_CHANGE_2, DEVICE_REMOVAL, REGULAR_READING,
                  MIDWAY_READING, CONTRACT_CHANGE, DEVICE_PARAMETER_CHANGE, BALANCING_ZONE_CHANGE, OTHER]
    end

    def qualities
      @quality ||= [NOT_USABLE, SUBSTITUE_VALUE, ENERGY_QUANTITY_SUMMARIZED, FORECAST_VALUE, READ_OUT,
                  PROPOSED_VALUE]
    end

    def sources
      @source ||= [BUZZN_SYSTEMS, CUSTOMER_LSG, LSN, VNB, THIRD_PARTY_MSB_MDL, OTHER, USER_INPUT, SLP, SEP_PV, SEP_BHKW]
    end
  end

  field :contract_id
  field :register_id
  field :timestamp,               type: DateTime
  field :energy_milliwatt_hour, type: Integer
  field :power_milliwatt,       type: Integer
  field :reason
  field :source
  field :quality
  field :load_course_time_series, type: Float
  field :state
  field :meter_serialnumber

  index({ register_id: 1 })
  index({ timestamp: 1 })
  index({ register_id: 1, timestamp: 1 })
  index({ register_id: 1, source: 1 })

  validate :energy_milliwatt_hour_has_to_grow, if: :user_input?
  def user_input?; source == USER_INPUT; end

  validates :reason, inclusion: { in: reasons }
  validates :quality, inclusion: { in: qualities }
  validates :source, inclusion: { in: sources}
  validates :register_id, presence: true
  validates :timestamp, presence: true
  validates :energy_milliwatt_hour, presence: true
  validates :power_milliwatt, presence: false
  validates :meter_serialnumber, presence: true
  validates_uniqueness_of :timestamp, scope: [:register_id, :reason], message: 'already available for given register and reason'

  scope :in_year, -> (year) { where(:timestamp.gte => Time.new(year, 1, 1)).where(:timestamp.lte => Time.new(year, 12, 31, 23, 59, 59)) }
  scope :at, -> (timestamp) do
    timestamp = case timestamp
                when DateTime
                  timestamp.to_time
                when Time
                  timestamp
                when Date
                  timestamp.to_time
                when Fixnum
                  Time.at(timestamp)
                else
                  raise ArgumentError.new("timestamp not a Time or Fixnum or Date: #{timestamp.class}")
                end
    where(:timestamp.gte => timestamp).where(:timestamp.lt => timestamp + 1.second)
  end

  scope :by_register_id, -> (register_id) { where(register_id: register_id) }

  scope :by_reason, lambda {|*reasons|
    reasons.each do |reason|
      raise ArgumentError.new('Undefined constant "' + reason + '". Only use constants defined by Reading.reasons.') unless self.reasons.include?(reason)
    end
    self.where(:reason.in => reasons)
  }

  scope :without_reason, lambda {|*reasons|
    reasons.each do |reason|
      raise ArgumentError.new('Undefined constant "' + reason + '". Only use constants defined by Reading.reasons.') unless self.reasons.include?(reason)
    end
    self.where(:reason.nin => reasons)
  }

  def register
    Register::Base.find(self.register_id) if self.register_id
  end

  def energy_milliwatt_hour_has_to_grow
    reading_before = last_before_user_input
    reading_after = next_after_user_input
    if !reading_before.nil? && reading_before[:energy_milliwatt_hour] > energy_milliwatt_hour
      self.errors.add(:energy_milliwatt_hour, "is lower than the last one:" + (reading_before[:energy_milliwatt_hour]/1000000).to_s)
    end
    if !reading_after.nil? && reading_after[:energy_milliwatt_hour] < energy_milliwatt_hour
      self.errors.add(:energy_milliwatt_hour, "is greater than the next one:" + (reading_after[:energy_milliwatt_hour]/1000000).to_s)
    end
  end






  def self.all_by_register_id(register_id)
    pipe = [
      { "$match" => {
          register_id: {
            "$in" => [register_id]
          }
        }
      },
      { "$sort" => {
          timestamp: 1
        }
      }
    ]
    return Reading.collection.aggregate(pipe).to_a
  end

  def self.all_by_register_id_and_source(register_id, source)
    pipe = [
      { "$match" => {
          register_id: {
            "$in" => [register_id]
          },
          source:{
            "$in" => [source]
          }
        }
      },
      { "$sort" => {
          timestamp: 1
        }
      }
    ]
    return Reading.collection.aggregate(pipe).to_a
  end

  def last_before_user_input
    pipe = [
      { "$match" => {
          register_id: {
            "$in" => [register_id]
          },
          source:{
            "$in" => ['user_input']
          },
          timestamp: {
            "$lt"  => timestamp.utc
          }
        }
      },
      { "$sort" => {
          timestamp: -1
        }
      },
      { "$limit" => 1 }
    ]
    return Reading.collection.aggregate(pipe).first
  end

  def next_after_user_input
    pipe = [
      { "$match" => {
          register_id: {
            "$in" => [register_id]
          },
          source:{
            "$in" => ['user_input']
          },
          timestamp: {
            "$gt"  => timestamp.utc
          }
        }
      },
      { "$sort" => {
          timestamp: -1
        }
      },
      { "$limit" => 1 }
    ]
    return Reading.collection.aggregate(pipe).first
  end




end
