module Buzzn::StandardProfile
  class Facade

    def query_value(profile, timestamp, keys)
      only = ['timestamp']
      only << 'energy_milliwatt_hour' if keys.include?('energy')
      only << 'power_milliwatt' if keys.include?('power')
      Reading.where(:timestamp.gte => timestamp, source: profile).only(only).first
    end

    def query_range(profile, from, to, resolution, keys)
      source = { source: { "$in" => [profile] } }

      resolution_formats = {
        year_to_months:     ['year', 'month'],
        month_to_days:      ['year', 'month', 'dayOfMonth'],
        week_to_days:       ['year', 'month', 'dayOfMonth'],
        day_to_hours:       ['year', 'month', 'dayOfMonth', 'hour'],
        day_to_minutes:     ['year', 'month', 'dayOfMonth', 'hour', 'minute'],
        hour_to_minutes:    ['year', 'month', 'dayOfMonth', 'hour', 'minute'],
        minute_to_seconds:  ['year', 'month', 'dayOfMonth', 'hour', 'minute', 'second']
      }
      resolution_format = resolution_formats[resolution]

      if resolution == :year_to_months
        @offset = (from + 6.month).utc_offset*1000
      else
        @offset = from.utc_offset*1000
      end


      # start pipe
      pipe = []


      # match
      match = {
                "$match" => {
                  timestamp: {
                    "$gte"  => from.to_datetime,
                    "$lt"  => to.to_datetime
                  }
                }
              }
      match["$match"].merge!(source)
      pipe << match




      # project
      project = {
                  "$project" => {
                    source: 1,
                    timestamp: 1
                  }
                }
      project["$project"].merge!(energy_milliwatt_hour: 1) if keys.include?('energy')
      project["$project"].merge!(power_milliwatt: 1) if keys.include?('power')
      formats = {}
      resolution_format.each do |format|
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
      if keys.include?('energy')
        group["$group"].merge!(firstEnergyMilliwattHour: { "$first" => "$energy_milliwatt_hour" })
        group["$group"].merge!(lastEnergyMilliwattHour:  { "$last"  => "$energy_milliwatt_hour" })
      end
      if keys.include?('power')
        group["$group"].merge!(avgPowerMilliwatt: { "$avg" => "$power_milliwatt" })
      end
      formats = {_id: {}}
      resolution_format.each do |format|
        formats[:_id].merge!({ "#{format.gsub('OfMonth','')}ly" => "$#{format.gsub('OfMonth','')}ly" })
      end
      group["$group"].merge!(formats)
      pipe << group





      # project
      project = {
                  "$project" => {
                    source: 1,
                    firstTimestamp:         "$firstTimestamp",
                    lastTimestamp:          "$lastTimestamp"
                  }
                }
      if keys.include?('energy')
        project["$project"].merge!(sumEnergyMilliwattHour: { "$subtract" => [ "$lastEnergyMilliwattHour", "$firstEnergyMilliwattHour" ] })
      end
      if keys.include?('power')
        project["$project"].merge!(avgPowerMilliwatt: "$avgPowerMilliwatt")
      end
      pipe << project



      # sort
      sort =  {
                "$sort" => {
                  _id: 1
                }
              }
      pipe << sort


      Reading.collection.aggregate(pipe)
    end







  end
end
