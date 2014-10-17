class Reading
  include Mongoid::Document

  field :contract_id,   type: Integer
  field :register_id,   type: Integer
  field :timestamp,     type: DateTime
  field :watt_hour,     type: Integer
  field :reason
  field :source
  field :quality
  field :load_course_time_series, type: Float
  field :state

  index({ register_id: 1 })
  index({ timestamp: 1 })


  def self.aggregate(resolution_format, register_id='slp')
    resolution_formats = {
      year_to_months: ['year', 'month'],
      month_to_days:  ['month', 'dayOfMonth'],
      day_to_hours:   ['dayOfMonth', 'hour']
    }
    resolution = resolution_formats[resolution_format]


    @time_zone  = 'Berlin'
    date        = Time.now
    @location_time_now = ActiveSupport::TimeZone[@time_zone].local(date.year, date.month, date.day)


    case resolution_format
    when :year_to_months
      @start_time = @location_time_now.beginning_of_year
      @end_time   = @location_time_now.end_of_year
    when :month_to_days
      @start_time = @location_time_now.beginning_of_month
      @end_time   = @location_time_now.end_of_month
    when :day_to_hours
      @start_time = @location_time_now.beginning_of_day
      @end_time   = @location_time_now.end_of_day
    else
      puts "You gave me #{resolution_format} -- I have no idea what to do with that."
    end

    pipe = []

    match = { "$match" => {
                timestamp: {
                  "$gte" => @start_time,
                  "$lt"  => @end_time
                }
              }
            }
    if register_id == 'slp'
      register_or_slp = { source: { "$in" => ['slp'] } }
    else
      register_or_slp = { register_id: { "$in" => [register_id] } }
    end
    match["$match"].merge!(register_or_slp)
    pipe << match


    project = { "$project" => {
                  watt_hour: 1,
                  timestamp: 1
                }
              }
    formats = {}
    resolution.each do |format|
      formats.merge!({ "#{format.gsub('OfMonth','')}ly" => { "$#{format}" => "$timestamp" } })
    end
    project["$project"].merge!(formats)
    pipe << project


    group = { "$group" => {
                firstReading:   { "$first"  => "$watt_hour" },
                lastReading:    { "$last"   => "$watt_hour" },
                firstTimestamp: { "$first"  => "$timestamp" },
                lastTimestamp:  { "$last"   => "$timestamp" }
              }
            }
    group["$group"].merge!({_id: {
      "#{resolution.first.gsub('OfMonth','')}ly" => "$#{resolution.first.gsub('OfMonth','')}ly",
      "#{resolution.last.gsub('OfMonth','')}ly" => "$#{resolution.last.gsub('OfMonth','')}ly"
      }})
    pipe << group


    project = { "$project" => {
                  consumption: { "$subtract" => [ "$lastReading", "$firstReading" ] },
                  firstTimestamp: "$firstTimestamp",
                  lastTimestamp:  "$lastTimestamp"
                }
              }
    pipe << project


    sort = { "$sort" => {
                _id: 1
              }
            }
    pipe << sort


    return Reading.collection.aggregate(pipe)
  end







  def self.latest_by_register_id(register_id)
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




end