module Buzzn::StandardProfile
  class Facade

    def power_chart(profile, interval)
      source      = { source: { "$in" => [profile] } }
      keys        = ['power']
      collection  = aggregate(source, interval, keys)
      collection_to_hash(collection)
    end

    def energy_chart(profile, interval)
      source      = { source: { "$in" => [profile] } }
      keys        = ['energy']
      collection  = aggregate(source, interval, keys)
      collection_to_hash(collection)
    end


private

    def aggregate(source, interval, keys)
      resolution_formats = {
        year_to_months:     ['year', 'month'],
        month_to_days:      ['year', 'month', 'dayOfMonth'],
        week_to_days:       ['year', 'month', 'dayOfMonth'],
        day_to_hours:       ['year', 'month', 'dayOfMonth', 'hour'],
        day_to_minutes:     ['year', 'month', 'dayOfMonth', 'hour', 'minute'],
        hour_to_minutes:    ['year', 'month', 'dayOfMonth', 'hour', 'minute'],
        minute_to_seconds:  ['year', 'month', 'dayOfMonth', 'hour', 'minute', 'second']
      }
      resolution = resolution_formats[interval.resolution]

      @offset = interval.from.utc_offset*1000

      # start pipe
      pipe = []


      # match
      match = {
                "$match" => {
                  timestamp: {
                    "$gte"  => interval.from.utc,
                    "$lt"  => interval.to.utc
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

      project["$project"].merge!(energy_milliwatt_hour: 1) if keys.include?('energy')
      project["$project"].merge!(power_milliwatt: 1) if keys.include?('power')

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

      if keys.include?('energy')
        group["$group"].merge!(firstEnergyMilliwattHour: { "$first" => "$energy_milliwatt_hour" })
        group["$group"].merge!(lastEnergyMilliwattHour:  { "$last"  => "$energy_milliwatt_hour" })
      end

      if keys.include?('power')
        group["$group"].merge!(avgPowerMilliwatt: { "$avg" => "$power_milliwatt" })
      end

      formats = {_id: {}}

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

      if keys.include?('energy')
        project["$project"].merge!(sumEnergyMilliwattHour: { "$subtract" => [ "$lastEnergyMilliwattHour", "$firstEnergyMilliwattHour" ] })
        project["$project"].merge!(first: "$firstEnergyMilliwattHour")
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





    def collection_to_hash(collection, factor=1)
      items = []
      collection.each do |document|
        item = {'timestamp' => document['firstTimestamp']}

        if document['sumEnergyMilliwattHour']
          energy_milliwatt_hour = document['sumEnergyMilliwattHour'] * factor
          item.merge!('energy_milliwatt_hour' => energy_milliwatt_hour.to_i)
        end

        if document['avgPowerMilliwatt']
          power_milliwatt = document['avgPowerMilliwatt'] * factor
          item.merge!('power_milliwatt' => power_milliwatt.to_i)
        end

        items << item
      end
      return items
    end










  end
end
