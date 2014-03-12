class Measurement
  include Mongoid::Document

  field :meter_id,  type: Integer
  field :timestamp, type: DateTime
  field :wh,        type: Integer

  index({ meter_id: 1 })
  index({ timestamp: 1 })




  def self.this_day_to_hours_by_meter_id(meter_id)
    pipe = [
      { "$match" => {
          timestamp: {
            "$gte" => Time.at(DateTime.now.utc.beginning_of_day),
            "$lt"  => Time.at(DateTime.now.utc.end_of_day)
          },
          meter_id: {
            "$in" => [meter_id]
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
    return Measurement.collection.aggregate(pipe)
  end




end