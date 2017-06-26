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
    reading_before = Reading.last_before_user_input(register_id, timestamp)
    reading_after = Reading.next_after_user_input(register_id, timestamp)
    if !reading_before.nil? && reading_before[:energy_milliwatt_hour] > energy_milliwatt_hour
      self.errors.add(:energy_milliwatt_hour, "is lower than the last one:" + (reading_before[:energy_milliwatt_hour]/1000000).to_s)
    end
    if !reading_after.nil? && reading_after[:energy_milliwatt_hour] < energy_milliwatt_hour
      self.errors.add(:energy_milliwatt_hour, "is greater than the next one:" + (reading_after[:energy_milliwatt_hour]/1000000).to_s)
    end
  end

#A PY 770
  def user_input?
    source == 'user_input'
  end

  def self.power_resolutions
    %w{
      day_to_minutes
      hour_to_minutes
      minute_to_seconds
    }
  end

  def self.energy_resolutions
    %w{
      year_to_months
      month_to_days
      day_to_hours
    }
  end

  def self.time_range_from_timestamp_and_resolution(raw_timestamp, resolution)
    timestamp = raw_timestamp.to_datetime
    offset = timestamp.utc_offset*1000
    case resolution.to_sym
    when :year_to_months
      start_time = timestamp.beginning_of_year
      end_time   = start_time.next_year
      offset     = (start_time + 6.month).utc_offset*1000
    when :month_to_days
      start_time = timestamp.beginning_of_month
      end_time   = start_time.next_month
      end_time   += 1.day # we need a day overlap
    when :week_to_days
      start_time = timestamp.beginning_of_week
      end_time   = start_time.next_week
    when :day_to_hours
      start_time = timestamp.beginning_of_day
      end_time   = start_time + 1.day
    when :day_to_minutes
      start_time = timestamp.beginning_of_day
      end_time   = start_time + 1.day
    when :hour_to_minutes
      start_time = timestamp.beginning_of_hour
      end_time   = start_time + 1.hour
    when :minute_to_seconds
      start_time = timestamp.beginning_of_minute
      end_time   = start_time + 1.minute

    when :day
      start_time = timestamp.beginning_of_day
      end_time   = start_time + 1.day
    when :month
      start_time = timestamp.beginning_of_month
      end_time   = start_time.next_month
    when :year
      start_time = timestamp.beginning_of_year
      end_time   = start_time.next_year
      offset     = (start_time + 6.month).utc_offset*1000
    when :year_to_minutes
      start_time = timestamp.beginning_of_year
      end_time   = start_time.next_year
    when :month_to_minutes
      start_time = timestamp.beginning_of_month
      end_time   = start_time.next_month
    else
      puts "You gave me #{resolution_format} -- I have no idea what to do with that."
    end
    if end_time > Time.current.in_time_zone - (offset/1000).seconds
      end_time = Time.current.in_time_zone - (offset/1000).seconds
    end

    return start_time, end_time, offset
  end


  def self.aggregate(resolution_format, source, timestamp, keys)
    resolution_formats = {
      year_to_months:     ['year', 'month'],
      month_to_days:      ['year', 'month', 'dayOfMonth'],
      week_to_days:       ['year', 'month', 'dayOfMonth'],
      day_to_hours:       ['year', 'month', 'dayOfMonth', 'hour'],
      day_to_minutes:     ['year', 'month', 'dayOfMonth', 'hour', 'minute'],
      hour_to_minutes:    ['year', 'month', 'dayOfMonth', 'hour', 'minute'],
      minute_to_seconds:  ['year', 'month', 'dayOfMonth', 'hour', 'minute', 'second'],

      day:                ['year', 'month', 'dayOfMonth'],
      month:              ['year', 'month'],
      year:               ['year'],

      year_to_minutes:    ['year', 'month', 'dayOfMonth', 'hour', 'minute'],
      month_to_minutes:   ['year', 'month', 'dayOfMonth', 'hour', 'minute']
    }
    resolution = resolution_formats[resolution_format.to_sym]

    @start_time, @end_time, @offset = time_range_from_timestamp_and_resolution(timestamp, resolution_format)

    # start pipe
    pipe = []


    # match
    match = { "$match" => {
                timestamp: {
                  "$gte"  => @start_time,
                  "$lt"  => @end_time
                }
              }
            }
    match["$match"].merge!(source)
    pipe << match






    # project
    project = {
                "$project" => {
                  register_id: 1,
                  timestamp: 1
                }
              }

    project["$project"].merge!(energy_milliwatt_hour: 1) if keys.include?('energy_milliwatt_hour')
    project["$project"].merge!(power_milliwatt: 1) if keys.include?('power_milliwatt')

    formats = {}
    resolution.each do |format|
      formats.merge!({
        "#{format.gsub('OfMonth','')}ly" => {
          "$#{format}" => {
            "$add" => ["$timestamp", @offset]
          }
        }
      })
    end
    project["$project"].merge!(formats)
    pipe << project




    # group
    group = {
              "$group" => {
                firstTimestamp: { "$first"  => "$timestamp" },
                lastTimestamp:  { "$last"   => "$timestamp" }
              }
            }

    if keys.include?('energy_milliwatt_hour')
      group["$group"].merge!(firstEnergyMilliwattHour: { "$min" => "$energy_milliwatt_hour" })
      group["$group"].merge!(lastEnergyMilliwattHour:  { "$max"  => "$energy_milliwatt_hour" })
    end

    if keys.include?('energy_milliwatt_hour')
      group["$group"].merge!(firstEnergyMilliwattHour: { "$first" => "$energy_milliwatt_hour" })
      group["$group"].merge!(lastEnergyMilliwattHour:  { "$last"  => "$energy_milliwatt_hour" })
    end

    if keys.include?('power_milliwatt')
      group["$group"].merge!(avgPowerMilliwatt: { "$avg" => "$power_milliwatt" })
    end

    formats = {_id: {}}

    if source[:register_id] && source[:register_id]['$in'].size > 1
      formats[:_id].merge!({ "register_id" =>  "$register_id" })
    end

    resolution.each do |format|
      formats[:_id].merge!({ "#{format.gsub('OfMonth','')}ly" => "$#{format.gsub('OfMonth','')}ly" })
    end
    group["$group"].merge!(formats)
    pipe << group







    # project
    project = {
                "$project" => {
                  register_id: 1,
                  firstTimestamp:         "$firstTimestamp",
                  lastTimestamp:          "$lastTimestamp"
                }
              }

    if keys.include?('energy_milliwatt_hour')
      project["$project"].merge!(sumEnergyMilliwattHour: { "$subtract" => [ "$lastEnergyMilliwattHour", "$firstEnergyMilliwattHour" ] })
      project["$project"].merge!(first:  "$firstEnergyMilliwattHour")
    end

    if keys.include?('power_milliwatt')
      project["$project"].merge!(avgPowerMilliwatt: "$avgPowerMilliwatt")
    end

    pipe << project








    # group
    if source[:register_id] && source[:register_id]['$in'].size > 1
      group = {
                "$group" => {
                  firstTimestamp: { "$first" => "$firstTimestamp" }
                }
              }

      if keys.include?('energy_milliwatt_hour')
        group["$group"].merge!(sumEnergyMilliwattHour: {"$sum" => "$sumEnergyMilliwattHour"})
      end

      if keys.include?('power_milliwatt')
        group["$group"].merge!(avgPowerMilliwatt: {"$sum" => "$avgPowerMilliwatt"})
      end

      formats = {_id: {}}

      resolution.each do |format|
        formats[:_id].merge!({ "#{format.gsub('OfMonth','')}ly" =>  "$_id.#{format.gsub('OfMonth','')}ly" })
      end
      group["$group"].merge!(formats)
      pipe << group
    end






    # sort
    sort = {
            "$sort" => {
                _id: 1
              }
            }
    pipe << sort


    result = Reading.collection.aggregate(pipe)

    if keys.include?('energy_milliwatt_hour') && resolution_format.to_sym == :month_to_days
      entries = result.collect { |entry| entry }
      entries[0..-2].each_with_index do |current,i|
        current['sumEnergyMilliwattHour'] = entries[i + 1]['first'] - current['first']
      end
      id = entries.first['_id']
      if entries.last['_id'].to_a[0..-2] == id.to_a[0..-2]
        entries
      else
        entries[0..-2]
      end
    else
      result
    end
  end







  def self.last_by_register_id(register_id)
    pipe = [
      { "$match" => {
          register_id: {
            "$in" => [register_id]
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


  def self.last_two_by_register_id(register_id)
    pipe = [
      { "$match" => {
          register_id: {
            "$in" => [register_id]
          }
        }
      },
      { "$sort" => {
          timestamp: -1
        }
      },
      { "$limit" => 2 }
    ]
    return Reading.collection.aggregate(pipe)
  end


  def self.first_by_register_id(register_id)
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
      },
      { "$limit" => 1 }
    ]
    return Reading.collection.aggregate(pipe).first
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

  def self.last_before_user_input(register_id, input_timestamp)
    pipe = [
      { "$match" => {
          register_id: {
            "$in" => [register_id]
          },
          source:{
            "$in" => ['user_input']
          },
          timestamp: {
            "$lt"  => input_timestamp.utc
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

  def self.next_after_user_input(register_id, input_timestamp)
    pipe = [
      { "$match" => {
          register_id: {
            "$in" => [register_id]
          },
          source:{
            "$in" => ['user_input']
          },
          timestamp: {
            "$gt"  => input_timestamp.utc
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

  def self.latest_fake_data(source)
    values = []
    readings = Reading.where(:timestamp.gte => (Time.current - 15.minutes), :timestamp.lt => (Time.current + 15.minutes), source: source)
    if readings.any?
      firstTimestamp = readings.first.timestamp.to_i*1000
      firstValue = readings.first.power_milliwatt/1000
      values << [firstTimestamp, firstValue]
      return values
    end
    return nil
  end




end
