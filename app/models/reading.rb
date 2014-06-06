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
    pipe = [
      { "$match" => {
          timestamp: {
            "$gte" => Time.at(DateTime.now.beginning_of_day),
            "$lt"  => Time.at(DateTime.now.end_of_day)
          },
          register_id: {
            "$in" => [register_id]
          }
        }
      },
      { "$project" => {
          wh: 1,
          hourly: { "$hour" => "$timestamp" }
        }
      },
      { "$group" => {
          _id: "$hourly",
          firstReading: { "$last"  => "$wh" },
          lastReading: { "$first" => "$wh" }
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