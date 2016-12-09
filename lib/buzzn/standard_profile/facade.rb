module Buzzn::Discovergy
  class Facade

    def readings(broker, interval, mode, collection=false)
    end



    def aggregate(resolution_format, source, timestamp, keys)
      resolution_formats = {
        year_to_months:     ['year', 'month'],
        month_to_days:      ['year', 'month', 'dayOfMonth'],
        week_to_days:       ['year', 'month', 'dayOfMonth'],
        day_to_hours:       ['year', 'month', 'dayOfMonth', 'hour'],
        day_to_minutes:     ['year', 'month', 'dayOfMonth', 'hour', 'minute'],
        hour_to_minutes:    ['year', 'month', 'dayOfMonth', 'hour', 'minute'],
        minute_to_seconds:  ['year', 'month', 'dayOfMonth', 'hour', 'minute', 'second']
      }
      resolution = resolution_formats[resolution_format.to_sym]

      @start_time, @end_time, @offset = time_range_from_timestamp_and_resolution(timestamp, resolution_format)

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
      match["$match"].merge!(source)
      pipe << match






      # project
      project = {
                  "$project" => {
                    register_id: 1,
                    timestamp: 1
                  }
                }

      project["$project"].merge!(energy_a_milliwatt_hour: 1) if keys.include?('energy_a_milliwatt_hour')
      project["$project"].merge!(energy_b_milliwatt_hour: 1) if keys.include?('energy_b_milliwatt_hour')
      project["$project"].merge!(power_a_milliwatt: 1) if keys.include?('power_a_milliwatt')
      project["$project"].merge!(power_b_milliwatt: 1) if keys.include?('power_b_milliwatt')

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

      if keys.include?('energy_a_milliwatt_hour')
        group["$group"].merge!(firstEnergyAMilliwattHour: { "$min" => "$energy_a_milliwatt_hour" })
        group["$group"].merge!(lastEnergyAMilliwattHour:  { "$max"  => "$energy_a_milliwatt_hour" })
      end

      if keys.include?('energy_b_milliwatt_hour')
        group["$group"].merge!(firstEnergyBMilliwattHour: { "$first" => "$energy_b_milliwatt_hour" })
        group["$group"].merge!(lastEnergyBMilliwattHour:  { "$last"  => "$energy_b_milliwatt_hour" })
      end

      if keys.include?('power_a_milliwatt')
        group["$group"].merge!(avgPowerAMilliwatt: { "$avg" => "$power_a_milliwatt" })
      end

      if keys.include?('power_b_milliwatt')
        group["$group"].merge!(avgPowerBMilliwatt: { "$avg" => "$power_b_milliwatt" })
      end

      formats = {_id: {}}

      if source[:register_id] && source[:register_id]['$in'].size > 1
        formats[:_id].merge!({ "register_id" =>  "$register_id" })
      end

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

      if keys.include?('energy_a_milliwatt_hour')
        project["$project"].merge!(sumEnergyAMilliwattHour: { "$subtract" => [ "$lastEnergyAMilliwattHour", "$firstEnergyAMilliwattHour" ] })
        project["$project"].merge!(first:  "$firstEnergyAMilliwattHour")
      end

      if keys.include?('energy_b_milliwatt_hour')
        project["$project"].merge!(sumEnergyBMilliwattHour: { "$subtract" => [ "$lastEnergyBMilliwattHour", "$firstEnergyBMilliwattHour" ] })
      end

      if keys.include?('power_a_milliwatt')
        project["$project"].merge!(avgPowerAMilliwatt: "$avgPowerAMilliwatt")
      end

      if keys.include?('power_b_milliwatt')
        project["$project"].merge!(avgPowerBMilliwatt: "$avgPowerBMilliwatt")
      end

      pipe << project








      # group
      if source[:register_id] && source[:register_id]['$in'].size > 1
        group = {
                  "$group" => {
                    firstTimestamp: { "$first" => "$firstTimestamp" }
                  }
                }

        if keys.include?('energy_a_milliwatt_hour')
          group["$group"].merge!(sumEnergyAMilliwattHour: {"$sum" => "$sumEnergyAMilliwattHour"})
        end

        if keys.include?('energy_b_milliwatt_hour')
          group["$group"].merge!(sumEnergyBMilliwattHour: {"$sum" => "$sumEnergyBMilliwattHour"})
        end

        if keys.include?('power_a_milliwatt')
          group["$group"].merge!(avgPowerAMilliwatt: {"$sum" => "$avgPowerAMilliwatt"})
        end

        if keys.include?('power_b_milliwatt')
          group["$group"].merge!(avgPowerBMilliwatt: {"$sum" => "$avgPowerBMilliwatt"})
        end

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


      Reading.collection.aggregate(pipe)
    end





  end
end
