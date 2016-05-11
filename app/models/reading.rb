class Reading
  include Mongoid::Document
  include Authority::Abilities

  after_create :push_reading

  field :contract_id,   type: String
  field :metering_point_id,   type: String
  field :timestamp,     type: DateTime
  field :watt_hour,     type: Integer
  field :power,         type: Integer
  field :reason
  field :source
  field :quality
  field :load_course_time_series, type: Float
  field :state

  index({ metering_point_id: 1 })
  index({ timestamp: 1 })
  index({ metering_point_id: 1, timestamp: 1 })
  index({ metering_point_id: 1, source: 1 })

  validate :watt_hour_has_to_grow, if: :user_input?

  def metering_point
    MeteringPoint.find(self.metering_point_id)
  end

  def watt_hour_has_to_grow
    reading_before = Reading.last_before_user_input(metering_point_id, timestamp)
    if !reading_before.nil? && reading_before[:watt_hour] > watt_hour
      self.errors.add(:watt_hour, "is lower than the last one")
    end
  end

#A PY 770
  def user_input?
    source == 'user_input'
  end

  def self.aggregate(resolution_format, metering_point_ids=['slp'], timestamp)
    resolution_formats = {
      year_to_months:   ['year', 'month'],
      month_to_days:    ['year', 'month', 'dayOfMonth'],
      week_to_days:     ['year', 'month', 'dayOfMonth'],
      day_to_hours:     ['year', 'month', 'dayOfMonth', 'hour'],
      day_to_minutes:   ['year', 'month', 'dayOfMonth', 'hour', 'minute'],
      hour_to_minutes:  ['year', 'month', 'dayOfMonth', 'hour', 'minute'],
      minute_to_seconds:['year', 'month', 'dayOfMonth', 'hour', 'minute', 'second'],

      day:              ['year', 'month', 'dayOfMonth'],
      month:            ['year', 'month'],
      year:             ['year'],

      year_to_minutes:  ['year', 'month', 'dayOfMonth', 'hour', 'minute'],
      month_to_minutes: ['year', 'month', 'dayOfMonth', 'hour', 'minute']
    }
    resolution = resolution_formats[resolution_format.to_sym]

    case resolution_format.to_sym
    when :year_to_months
      @start_time = timestamp.beginning_of_year
      @end_time   = timestamp.end_of_year
    when :month_to_days
      @start_time = timestamp.beginning_of_month
      @end_time   = timestamp.end_of_month
    when :week_to_days
      @start_time = timestamp.beginning_of_week
      @end_time   = timestamp.end_of_week
    when :day_to_hours
      @start_time = timestamp.beginning_of_day
      @end_time   = timestamp.end_of_day
    when :day_to_minutes
      @start_time = timestamp.beginning_of_day
      @end_time   = timestamp.end_of_day
    when :hour_to_minutes
      @start_time = timestamp.beginning_of_hour
      @end_time   = timestamp.end_of_hour
    when :minute_to_seconds
      @start_time = timestamp.beginning_of_minute
      @end_time   = timestamp.end_of_minute
    when :day
      @start_time = timestamp.beginning_of_day
      @end_time   = timestamp.end_of_day
    when :month
      @start_time = timestamp.beginning_of_month
      @end_time   = timestamp.end_of_month
    when :year
      @start_time = timestamp.beginning_of_year
      @end_time   = timestamp.end_of_year
    when :year_to_minutes
      @start_time = timestamp.beginning_of_year
      @end_time   = timestamp.end_of_year
    when :month_to_minutes
      @start_time = timestamp.beginning_of_month
      @end_time   = timestamp.end_of_month
    else
      puts resolution_format.class
      puts resolution
      puts "You gave me #{resolution_format} -- I have no idea what to do with that."
      return
    end

    # if (metering_point_ids.include?('slp') || metering_point_ids.include?('sep_pv') || metering_point_ids.include?('sep_bhkw')) && @end_time > Time.now
    #   @end_time = Time.now
    # end

    # start pipe
    pipe = []


    # match
    match = { "$match" => {
                timestamp: {
                  "$gte" => @start_time,
                  "$lt"  => @end_time
                }
              }
            }

    if metering_point_ids[0] == 'slp'
      metering_point_or_fake = { source: { "$in" => ['slp'] } }
    elsif metering_point_ids[0] == 'sep_pv'
      metering_point_or_fake = { source: { "$in" => ['sep_pv'] } }
    elsif metering_point_ids[0] == 'sep_bhkw'
      metering_point_or_fake = { source: { "$in" => ['sep_bhkw'] } }
    #elsif metering_point_ids[0] == 'user_input'
    #  metering_point_or_fake = { source: { "$in" => ['user_input'] } }
    else
      metering_point_or_fake = { metering_point_id: { "$in" => metering_point_ids } }
    end
    match["$match"].merge!(metering_point_or_fake)
    pipe << match






    # project
    project = {
                "$project" => {
                  metering_point_id: 1,
                  watt_hour: 1,
                  power: 1,
                  timestamp: 1
                }
              }
    formats = {}
    resolution.each do |format|

      offset = timestamp.utc_offset*1000

      formats.merge!({
        "#{format.gsub('OfMonth','')}ly" => {
          "$#{format}" => {
            "$add" => ["$timestamp", offset]
          }
        }
      })
    end
    project["$project"].merge!(formats)
    pipe << project







    # group
    group = {
              "$group" => {
                firstWattHour:  { "$first"  => "$watt_hour" },
                lastWattHour:   { "$last"   => "$watt_hour" },
                avgPower:       { "$avg"    => "$power" },
                firstTimestamp: { "$first"  => "$timestamp" },
                lastTimestamp:  { "$last"  => "$timestamp" },
              }
            }
    formats = {_id: {}}

    if metering_point_ids.size > 1
      formats[:_id].merge!({ "metering_point_id" =>  "$metering_point_id" })
    end

    resolution.each do |format|
      formats[:_id].merge!({ "#{format.gsub('OfMonth','')}ly" => "$#{format.gsub('OfMonth','')}ly" })
    end
    group["$group"].merge!(formats)
    pipe << group







    # project
    project = {
                "$project" => {
                  metering_point_id: 1,
                  consumption:  { "$subtract" => [ "$lastWattHour", "$firstWattHour" ] },
                  avgPower:       "$avgPower",
                  firstTimestamp: "$firstTimestamp",
                  lastTimestamp:  "$lastTimestamp"
                }
              }
    pipe << project








    # group
    if metering_point_ids.size > 1
      group = {
                "$group" => {
                  avgPower:      { "$sum"  => "$avgPower" },
                  consumption:   { "$sum"  => "$consumption" }
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







  def self.last_by_metering_point_id(metering_point_id)
    pipe = [
      { "$match" => {
          metering_point_id: {
            "$in" => [metering_point_id]
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


  def self.last_two_by_metering_point_id(metering_point_id)
    pipe = [
      { "$match" => {
          metering_point_id: {
            "$in" => [metering_point_id]
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


  def self.first_by_metering_point_id(metering_point_id)
    pipe = [
      { "$match" => {
          metering_point_id: {
            "$in" => [metering_point_id]
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

  def self.all_by_metering_point_id(metering_point_id)
    pipe = [
      { "$match" => {
          metering_point_id: {
            "$in" => [metering_point_id]
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

  def self.last_before_user_input(metering_point_id, input_timestamp)
    pipe = [
      { "$match" => {
          metering_point_id: {
            "$in" => [metering_point_id]
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
      firstValue = readings.first.power/1000
      values << [firstTimestamp, firstValue]
      return values
    end
    return nil
  end

  private

    def push_reading
      if self.source != 'slp' && self.source != 'sep_bhkw' && self.source != 'sep_pv' && self.source != 'user_input' # don't push non-smart records
        if self.timestamp > 30.seconds.ago # don't push old readings
          Sidekiq::Client.push({
           'class' => PushReadingWorker,
           'queue' => :default,
           'args' => [
                      metering_point_id,
                      watt_hour,
                      power/1000,
                      timestamp.to_i*1000
                     ]
          })
        end
      end
    end






end
