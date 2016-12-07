require 'buzzn/guarded_crud'
class Reading
  include Mongoid::Document
  include Authority::Abilities

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

  index({ register_id: 1 })
  index({ timestamp: 1 })
  index({ register_id: 1, timestamp: 1 })
  index({ register_id: 1, source: 1 })

  validate :energy_milliwatt_hour_has_to_grow, if: :user_input?

  # methods from Buzzn:GuardedCrud
  def self.guarded_retrieve(user, id)
    result = find(id)
    unless result.readable_by?(user)
      raise Buzzn::PermissionDenied.new
    end
    result
  end

  def register
    Register::Base.find(self.register_id) if self.register_id
  end

  def energy_milliwatt_hour_has_to_grow
    reading_before = Reading.last_before_user_input(register_id, timestamp)
    reading_after = Reading.next_after_user_input(register_id, timestamp)
    if !reading_before.nil? && reading_before[:energy_a_milliwatt_hour] > energy_a_milliwatt_hour
      self.errors.add(:energy_a_milliwatt_hour, "is lower than the last one:" + (reading_before[:energy_a_milliwatt_hour]/1000000).to_s)
    end
    if !reading_after.nil? && reading_after[:energy_a_milliwatt_hour] < energy_a_milliwatt_hour
      self.errors.add(:energy_a_milliwatt_hour, "is greater than the next one:" + (reading_after[:energy_a_milliwatt_hour]/1000000).to_s)
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

    project["$project"].merge!(energy_a_milliwatt_hour: 1) if keys.include?('energy_a_milliwatt_hour')
    project["$project"].merge!(energy_b_milliwatt_hour: 1) if keys.include?('energy_b_milliwatt_hour')
    project["$project"].merge!(power_a_milliwatt: 1) if keys.include?('power_a_milliwatt')
    project["$project"].merge!(power_b_milliwatt: 1) if keys.include?('power_b_milliwatt')

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

    if keys.include?('energy_a_milliwatt_hour')
      group["$group"].merge!(firstEnergyAMilliwattHour: { "$min" => "$energy_a_milliwatt_hour" })
      group["$group"].merge!(lastEnergyAMilliwattHour:  { "$max"  => "$energy_a_milliwatt_hour" })
    end

    if keys.include?('energy_b_milliwatt_hour')
      group["$group"].merge!(firstEnergyBMilliwattHour: { "$first" => "$energy_b_milliwatt_hour" })
      group["$group"].merge!(lastEnergyBMilliwattHour:  { "$last"  => "$energy_b_milliwatt_hour" })
    end

    if keys.include?('power_a_milliwatt')
      group["$group"].merge!(avgPowerAMilliwatt: { "$avg" => "$power_a_milliwatt" })
    end

    if keys.include?('power_b_milliwatt')
      group["$group"].merge!(avgPowerBMilliwatt: { "$avg" => "$power_b_milliwatt" })
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

    if keys.include?('energy_a_milliwatt_hour')
      project["$project"].merge!(sumEnergyAMilliwattHour: { "$subtract" => [ "$lastEnergyAMilliwattHour", "$firstEnergyAMilliwattHour" ] })
      project["$project"].merge!(first:  "$firstEnergyAMilliwattHour")
    end

    if keys.include?('energy_b_milliwatt_hour')
      project["$project"].merge!(sumEnergyBMilliwattHour: { "$subtract" => [ "$lastEnergyBMilliwattHour", "$firstEnergyBMilliwattHour" ] })
    end

    if keys.include?('power_a_milliwatt')
      project["$project"].merge!(avgPowerAMilliwatt: "$avgPowerAMilliwatt")
    end

    if keys.include?('power_b_milliwatt')
      project["$project"].merge!(avgPowerBMilliwatt: "$avgPowerBMilliwatt")
    end

    pipe << project








    # group
    if source[:register_id] && source[:register_id]['$in'].size > 1
      group = {
                "$group" => {
                  firstTimestamp: { "$first" => "$firstTimestamp" }
                }
              }

      if keys.include?('energy_a_milliwatt_hour')
        group["$group"].merge!(sumEnergyAMilliwattHour: {"$sum" => "$sumEnergyAMilliwattHour"})
      end

      if keys.include?('energy_b_milliwatt_hour')
        group["$group"].merge!(sumEnergyBMilliwattHour: {"$sum" => "$sumEnergyBMilliwattHour"})
      end

      if keys.include?('power_a_milliwatt')
        group["$group"].merge!(avgPowerAMilliwatt: {"$sum" => "$avgPowerAMilliwatt"})
      end

      if keys.include?('power_b_milliwatt')
        group["$group"].merge!(avgPowerBMilliwatt: {"$sum" => "$avgPowerBMilliwatt"})
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

    if keys.include?('energy_a_milliwatt_hour') && resolution_format.to_sym == :month_to_days
      entries = result.collect { |entry| entry }
      entries[0..-2].each_with_index do |current,i|
        current['sumEnergyAMilliwattHour'] = entries[i + 1]['first'] - current['first']
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
          },
          source:{
            "$in" => ['user_input']
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
      firstValue = readings.first.power_a_milliwatt/1000
      values << [firstTimestamp, firstValue]
      return values
    end
    return nil
  end




end
