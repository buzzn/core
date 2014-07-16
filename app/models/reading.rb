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






  def self.this_day_to_hours_by_register_id(register_id)

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
          dayly:  { "$dayOfMonth" => "$timestamp" },
          hourly: { "$hour" => "$timestamp" }
        }
      },
      { "$group" => {
          _id: { dayly: "$dayly", hourly: "$hourly"},
          firstReading: { "$last"  => "$watt_hour" },
          lastReading: { "$first" => "$watt_hour" }
        }
      },
      { "$project" => {
          hourReading: { "$subtract" => [ "$firstReading", "$lastReading" ] }
        }
      },
      { "$sort" => {
          _id: 1
        }
      }
    ]
    return Reading.collection.aggregate(pipe)
  end








  def self.this_day_to_hours_by_slp
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
          dayly:  { "$dayOfMonth" => "$timestamp" },
          hourly: { "$hour" => "$timestamp" }
        }
      },
      { "$group" => {
          _id: { dayly: "$dayly", hourly: "$hourly"},
          firstReading: { "$last"  => "$watt_hour" },
          lastReading: { "$first" => "$watt_hour" }
        }
      },
      { "$project" => {
          hourReading: { "$subtract" => [ "$firstReading", "$lastReading" ] }
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