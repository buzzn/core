module Buzzn::StandardProfile
  class Facade

    def query_value(profile, timestamp, units)
      only = ['timestamp', 'source']
      only << 'energy_milliwatt_hour' if units.include?('energy')
      only << 'power_milliwatt' if units.include?('power')
      Reading.where(:timestamp.gte => timestamp, source: profile).only(only).order_by(timestamp: 1).first
    end

    def query_range(profile, from, to, resolution, units)
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


      # start pipe
      pipe = []

      # sort
      sort =  {
                "$sort" => {
                  timestamp: 1
                }
              }
      pipe << sort

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

      # we bucket complete days/month/hours according to the date format so we need to
      # move the timestamp for calculating the date format at the beginning of the day.
      offset = 1000 * ((from + 1.day).beginning_of_day - from)

      project["$project"].merge!(energy_milliwatt_hour: 1) if units.include?('energy')
      project["$project"].merge!(power_milliwatt: 1) if units.include?('power')
      formats = {}
      resolution_format.each do |format|
        formats.merge!({
          "#{format.gsub('OfMonth','')}ly" => {
            "$#{format}" => { "$add" => [ "$timestamp", offset ] }
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
      if units.include?('energy')
        group["$group"].merge!(firstEnergyMilliwattHour: { "$first" => "$energy_milliwatt_hour" })
        group["$group"].merge!(lastEnergyMilliwattHour:  { "$last"  => "$energy_milliwatt_hour" })
      end
      if units.include?('power')
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
                    firstTimestamp: "$firstTimestamp",
                    lastTimestamp: "$lastTimestamp"
                  }
                }
      if units.include?('energy')
        project["$project"].merge!(sumEnergyMilliwattHour: { "$subtract" => [ "$lastEnergyMilliwattHour", "$firstEnergyMilliwattHour" ] })
      end
      if units.include?('power')
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
