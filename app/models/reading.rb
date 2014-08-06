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






  def self.day_to_hours_by_register_id(register_id)
    date = Time.now
    pipe = [
      { "$match" => {
          timestamp: {
            "$gte" => date.beginning_of_day,
            "$lt"  => date.end_of_day
          },
          register_id: {
            "$in" => [register_id]
          }
        }
      },
      { "$project" => {
          watt_hour: 1,
          timestamp: 1,
          dayly:  { "$dayOfMonth" => "$timestamp" },
          hourly: { "$hour" => "$timestamp" }
        }
      },
      { "$group" => {
          _id: { dayly: "$dayly", hourly: "$hourly"},
          firstReading:  { "$first"  => "$watt_hour" },
          lastReading:   { "$last" => "$watt_hour" },
          firstTimestamp: { "$first"   => "$timestamp" },
          lastTimestamp:  { "$last"   => "$timestamp" },

        }
      },
      { "$project" => {
          consumption: { "$subtract" => [ "$lastReading", "$firstReading" ] },
          firstTimestamp: "$firstTimestamp",
          lastTimestamp:  "$lastTimestamp"
        }
      },
      { "$sort" => {
          _id: 1
        }
      }
    ]
    return Reading.collection.aggregate(pipe)
  end








  def self.day_to_hours_by_slp
    date = Time.now

    pipe = [
      { "$match" => {
          timestamp: {
            "$gte" => date.beginning_of_day,
            "$lt"  => date.end_of_day
          },
          source: {
            "$in" => ['slp']
          }
        }
      },
      { "$project" => {
          watt_hour: 1,
          timestamp: 1,
          dayly:  { "$dayOfMonth" => "$timestamp" },
          hourly: { "$hour"       => "$timestamp" }
        }
      },
      { "$group" => {
          _id: { dayly: "$dayly", hourly: "$hourly"},
          firstReading:   { "$first"  => "$watt_hour" },
          lastReading:    { "$last"   => "$watt_hour" },
          firstTimestamp: { "$first"   => "$timestamp" },
          lastTimestamp:  { "$last"   => "$timestamp" },
        }
      },
      { "$project" => {
          consumption: { "$subtract" => [ "$lastReading", "$firstReading" ] },
          firstTimestamp: "$firstTimestamp",
          lastTimestamp:  "$lastTimestamp"
        }
      },
      { "$sort" => {
          _id: 1
        }
      }
    ]
    return Reading.collection.aggregate(pipe)
  end





  def self.month_to_days_by_slp
    date = Time.now.in_time_zone

    pipe = [
      { "$match" => {
          timestamp: {
            "$gte" => date.beginning_of_month,
            "$lt"  => date.end_of_month
          },
          source: {
            "$in" => ['slp']
          }
        }
      },
      { "$project" => {
          watt_hour: 1,
          timestamp: 1,
          monthly:  { "$month" => "$timestamp" },
          dayly:    { "$dayOfMonth" => "$timestamp" },
        }
      },
      { "$group" => {
          _id: { monthly: "$monthly", dayly: "$dayly"},
          firstReading:   { "$first"  => "$watt_hour" },
          lastReading:    { "$last"   => "$watt_hour" },
          firstTimestamp: { "$first"   => "$timestamp" },
          lastTimestamp:  { "$last"   => "$timestamp" },
        }
      },
      { "$project" => {
          consumption: { "$subtract" => [ "$lastReading", "$firstReading" ] },
          firstTimestamp: "$firstTimestamp",
          lastTimestamp:  "$lastTimestamp"
        }
      },
      { "$sort" => {
          _id: 1
        }
      }
    ]
    return Reading.collection.aggregate(pipe)
  end



  def self.year_to_months_by_slp
    date = Time.now

    pipe = [
      { "$match" => {
          timestamp: {
            "$gte" => date.beginning_of_year,
            "$lt"  => date.end_of_year
          },
          source: {
            "$in" => ['slp']
          }
        }
      },
      { "$project" => {
          watt_hour: 1,
          timestamp: 1,
          monthly:  { "$month" => "$timestamp" },
          yearly:    { "$year" => "$timestamp" },
        }
      },
      { "$group" => {
          _id: { monthly: "$monthly", yearly: "$yearly"},
          firstReading:   { "$first"  => "$watt_hour" },
          lastReading:    { "$last"   => "$watt_hour" },
          firstTimestamp: { "$first"   => "$timestamp" },
          lastTimestamp:  { "$last"   => "$timestamp" },
        }
      },
      { "$project" => {
          consumption: { "$subtract" => [ "$lastReading", "$firstReading" ]},
          firstTimestamp: "$firstTimestamp",
          lastTimestamp:  "$lastTimestamp"
        }
      },
      { "$sort" => {
          _id: 1
        }
      }
    ]
    return Reading.collection.aggregate(pipe)
  end





end