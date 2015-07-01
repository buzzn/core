class Reading
  include Mongoid::Document
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

  validate :watt_hour_has_to_grow, if: :user_input?


  def watt_hour_has_to_grow
    reading_before = Reading.last_before_user_input(metering_point_id, timestamp)
    puts reading_before
    if !reading_before.nil? && reading_before[:watt_hour] > watt_hour
      puts "ERROR"
      self.errors.add(:watt_hour, "is lower than the last one")
    end
  end

  def user_input?
    source == 'user_input'
  end

  def self.aggregate(resolution_format, metering_point_ids=['slp'], containing_timestamp=nil)
    resolution_formats = {
      year_to_months:   ['year', 'month'],
      month_to_days:    ['year', 'month', 'dayOfMonth'],
      week_to_days:     ['year', 'month', 'dayOfMonth', 'week', 'dayOfWeek'],
      day_to_hours:     ['year', 'month', 'dayOfMonth', 'week', 'dayOfWeek', 'hour'],
      day_to_minutes:   ['year', 'month', 'dayOfMonth', 'week', 'dayOfWeek', 'hour', 'minute'],
      hour_to_minutes:  ['year', 'month', 'dayOfMonth', 'week', 'dayOfWeek', 'hour', 'minute'],
      minute_to_seconds:['year', 'month', 'dayOfMonth', 'week', 'dayOfWeek', 'hour', 'minute', 'second'],

      day:              ['year', 'month', 'dayOfMonth'],
      month:            ['year', 'month'],
      year:             ['year'],

      year_to_minutes:  ['year', 'month', 'dayOfMonth', 'week', 'dayOfWeek', 'hour', 'minute'],
      month_to_minutes: ['year', 'month', 'dayOfMonth', 'week', 'dayOfWeek', 'hour', 'minute']
    }
    resolution = resolution_formats[resolution_format]


    @time_zone          = 'Berlin'
    date                = Time.now
    @location_time_now  = ActiveSupport::TimeZone[@time_zone].local(date.year, date.month, date.day, date.hour, date.min, date.sec)

    if containing_timestamp
      @location_time = DateTime.strptime((containing_timestamp.to_i/1000).to_s, "%s").in_time_zone
    else
      @location_time = @location_time_now
    end

    case resolution_format
    when :year_to_months
      @start_time = @location_time.beginning_of_year
      @end_time   = @location_time.end_of_year
    when :month_to_days
      @start_time = @location_time.beginning_of_month
      @end_time   = @location_time.end_of_month
    when :week_to_days
      @start_time = @location_time.beginning_of_week
      @end_time   = @location_time.end_of_week
    when :day_to_hours
      @start_time = @location_time.beginning_of_day
      @end_time   = @location_time.end_of_day
    when :day_to_minutes
      @start_time = @location_time.beginning_of_day
      @end_time   = @location_time.end_of_day
    when :hour_to_minutes
      @start_time = @location_time.beginning_of_hour
      @end_time   = @location_time.end_of_hour
    when :minute_to_seconds
      @start_time = @location_time.beginning_of_minute
      @end_time   = @location_time.end_of_minute
    when :day
      @start_time = @location_time.beginning_of_day
      @end_time   = @location_time.end_of_day
    when :month
      @start_time = @location_time.beginning_of_month
      @end_time   = @location_time.end_of_month
    when :year
      @start_time = @location_time.beginning_of_year
      @end_time   = @location_time.end_of_year
    when :year_to_minutes
      @start_time = @location_time.beginning_of_year
      @end_time   = @location_time.end_of_year
    when :month_to_minutes
      @start_time = @location_time.beginning_of_month
      @end_time   = @location_time.end_of_month
    else
      puts resolution_format.class
      puts "You gave me #{resolution_format} -- I have no idea what to do with that."
      return
    end

    # start pipe
    pipe = []


    # match
    match = { "$match" => {
                timestamp: {
                  "$gte" => @start_time.utc,
                  "$lt"  => @end_time.utc
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
      formats.merge!({ "#{format.gsub('OfMonth','')}ly" => { "$#{format}" => "$timestamp" } })
    end
    project["$project"].merge!(formats)
    pipe << project







    # group
    group = {
              "$group" => {
                firstWattHour:      { "$first"  => "$watt_hour" },
                lastWattHour:       { "$last"   => "$watt_hour" },
                avgPower:           { "$avg"    => "$power" },
                firstTimestamp:     { "$first"  => "$timestamp" },
                lastTimestamp:      { "$last"   => "$timestamp" }
              }
            }
    formats = {_id: {}}

    if metering_point_ids.size > 1
      formats[:_id].merge!({ "metering_point_id" =>  "$metering_point_id" })
    end

    resolution.each do |format|
      formats[:_id].merge!({ "#{format.gsub('OfMonth','')}ly" =>  "$#{format.gsub('OfMonth','')}ly" })
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





    # TODO this works but is ugly
    if Mongoid.sessions[:replica_set]
      hosts = Mongoid.sessions[:replica_set][:hosts]
      session = Moped::Session.new([ hosts.first ])
      call = session.with(database: :admin) do |admin|
        admin.command(ismaster: 1)
      end
      call[:hosts].delete(call[:primary])
      secondaries = call[:hosts]
      session = Moped::Session.new([ secondaries.sample ])
      session.use Mongoid.sessions[:replica_set][:database]
      session.with(read: :nearest)[:readings].aggregate(pipe)
    else
      return Reading.collection.aggregate(pipe)
    end
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
      firstValue = readings.first.watt_hour/10000000000.0
      lastTimestamp = readings.last.timestamp.to_i*1000
      lastValue = readings.last.watt_hour/10000000000.0
      values << [firstTimestamp, firstValue]
      values << [lastTimestamp, lastValue]
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