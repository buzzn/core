class Reading
  include Mongoid::Document
  include Authority::Abilities

  field :contract_id
  field :meter_id
  field :timestamp,               type: DateTime
  field :energy_a_milliwatt_hour, type: Integer
  field :energy_b_milliwatt_hour, type: Integer
  field :power_milliwatt,         type: Integer
  field :reason
  field :source
  field :quality
  field :load_course_time_series, type: Float
  field :state

  index({ meter_id: 1 })
  index({ timestamp: 1 })
  index({ meter_id: 1, timestamp: 1 })
  index({ meter_id: 1, source: 1 })

  validate :energy_milliwatt_hour_has_to_grow, if: :user_input?

  def meter
    Meter.find(self.meter_id)
  end

  def energy_milliwatt_hour_has_to_grow
    reading_before = Reading.last_before_user_input(meter_id, timestamp)
    if !reading_before.nil? && reading_before[:energy_milliwatt_hour] > energy_milliwatt_hour
      self.errors.add(:energy_milliwatt_hour, "is lower than the last one")
    end
  end

#A PY 770
  def user_input?
    source == 'user_input'
  end

  def self.aggregate(resolution_format, meter_ids=['slp'], timestamp)
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

    @offset = timestamp.utc_offset*1000

    case resolution_format.to_sym
    when :year_to_months
      @start_time = timestamp.beginning_of_year
      @end_time   = @start_time.next_year
      @offset     = (@start_time + 6.month).utc_offset*1000
    when :month_to_days
      @start_time = timestamp.beginning_of_month
      @end_time   = @start_time.next_month
    when :week_to_days
      @start_time = timestamp.beginning_of_week
      @end_time   = @start_time.next_week
    when :day_to_hours
      @start_time = timestamp.beginning_of_day
      @end_time   = @start_time + 1.day
    when :day_to_minutes
      @start_time = timestamp.beginning_of_day
      @end_time   = @start_time + 1.day
    when :hour_to_minutes
      @start_time = timestamp.beginning_of_hour
      @end_time   = @start_time + 1.hour
    when :minute_to_seconds
      @start_time = timestamp.beginning_of_minute
      @end_time   = @start_time + 1.minute
    when :day
      @start_time = timestamp.beginning_of_day
      @end_time   = @start_time + 1.day
    when :month
      @start_time = timestamp.beginning_of_month
      @end_time   = @start_time.next_month
    when :year
      @start_time = timestamp.beginning_of_year
      @end_time   = @start_time.next_year
      @offset     = (@start_time + 6.month).utc_offset*1000
    when :year_to_minutes
      @start_time = timestamp.beginning_of_year
      @end_time   = @start_time.next_year
    when :month_to_minutes
      @start_time = timestamp.beginning_of_month
      @end_time   = @start_time.next_month
    else
      puts resolution_format.class
      puts resolution
      puts "You gave me #{resolution_format} -- I have no idea what to do with that."
      return
    end


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


    if meter_ids[0] == 'slp'
      metering_point_or_fake = { source: { "$in" => ['slp'] } }
    elsif meter_ids[0] == 'sep_pv'
      metering_point_or_fake = { source: { "$in" => ['sep_pv'] } }
    elsif meter_ids[0] == 'sep_bhkw'
      metering_point_or_fake = { source: { "$in" => ['sep_bhkw'] } }
    else
      metering_point_or_fake = { meter_id: { "$in" => meter_ids } }
    end
    match["$match"].merge!(metering_point_or_fake)
    pipe << match






    # project
    project = {
                "$project" => {
                  meter_id: 1,
                  energy_a_milliwatt_hour: 1,
                  energy_b_milliwatt_hour: 1,
                  power_milliwatt: 1,
                  timestamp: 1
                }
              }
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
                firstEnergyAMilliWattHour:  { "$first"  => "$energy_a_milliwatt_hour" },
                lastEnergyAMilliWattHour:   { "$last"   => "$energy_a_milliwatt_hour" },
                firstEnergyBMilliWattHour:  { "$first"  => "$energy_b_milliwatt_hour" },
                lastEnergyBMilliWattHour:   { "$last"   => "$energy_b_milliwatt_hour" },
                avgPowerMilliwatt:          { "$avg"    => "$power_milliwatt" },
                firstTimestamp:             { "$first"  => "$timestamp" },
                lastTimestamp:              { "$last"   => "$timestamp" },
              }
            }
    formats = {_id: {}}

    if meter_ids.size > 1
      formats[:_id].merge!({ "meter_id" =>  "$meter_id" })
    end

    resolution.each do |format|
      formats[:_id].merge!({ "#{format.gsub('OfMonth','')}ly" => "$#{format.gsub('OfMonth','')}ly" })
    end
    group["$group"].merge!(formats)
    pipe << group







    # project
    project = {
                "$project" => {
                  meter_id: 1,
                  sumEnergyAMilliWattHour: { "$subtract" => [ "$lastEnergyAMilliWattHour", "$firstEnergyAMilliWattHour" ] },
                  sumEnergyBMilliWattHour: { "$subtract" => [ "$lastEnergyBMilliWattHour", "$firstEnergyBMilliWattHour" ] },
                  avgPowerMilliwatt:      "$avgPowerMilliwatt",
                  firstTimestamp:         "$firstTimestamp",
                  lastTimestamp:          "$lastTimestamp"
                }
              }
    pipe << project








    # group
    if meter_ids.size > 1
      group = {
                "$group" => {
                  avgPowerMilliwatt:       {"$sum"   => "$avgPowerMilliwatt" },
                  sumEnergyAMilliWattHour: {"$sum"   => "$sumEnergyAMilliWattHour" },
                  sumEnergyBMilliWattHour: {"$sum"   => "$sumEnergyBMilliWattHour" },
                  firstTimestamp:          {"$first" => "$firstTimestamp" }
                }
              }
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



    return Reading.collection.aggregate(pipe)
  end







  def self.last_by_meter_id(meter_id)
    pipe = [
      { "$match" => {
          meter_id: {
            "$in" => [meter_id]
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


  def self.last_two_by_meter_id(meter_id)
    pipe = [
      { "$match" => {
          meter_id: {
            "$in" => [meter_id]
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


  def self.first_by_meter_id(meter_id)
    pipe = [
      { "$match" => {
          meter_id: {
            "$in" => [meter_id]
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

  def self.all_by_meter_id(meter_id)
    pipe = [
      { "$match" => {
          meter_id: {
            "$in" => [meter_id]
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
    return Reading.collection.aggregate(pipe)
  end

  def self.last_before_user_input(meter_id, input_timestamp)
    pipe = [
      { "$match" => {
          meter_id: {
            "$in" => [meter_id]
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

  def self.latest_fake_data(source)
    values = []
    readings = Reading.where(:timestamp.gte => (Time.now - 15.minutes), :timestamp.lt => (Time.now + 15.minutes), source: source)
    if readings.any?
      firstTimestamp = readings.first.timestamp.to_i*1000
      firstValue = readings.first.milliwatt/1000
      values << [firstTimestamp, firstValue]
      return values
    end
    return nil
  end




end
