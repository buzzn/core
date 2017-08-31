module Buzzn::StandardProfile
  class Facade

    ENERGY = 'energy_milliwatt_hour'.freeze
    POWER  = 'power_milliwatt'.freeze
    SUM    = 'sumEnergyMilliwattHour'.freeze
    AVG    = 'avgPowerMilliwatt'.freeze
    FIRST  = 'firstEnergyMilliwattHour'.freeze
    LAST   = 'lastEnergyMilliwattHour'.freeze
    BUCKET = 'firstTimestamp'.freeze

    SELECTORS = {
      year:    ['year', 'month'].freeze,
      month:   ['month', 'dayOfMonth'].freeze,
      day:     ['hour', 'fifteen'].freeze,
      hour:    ['minute'].freeze
    }.freeze

    INITIAL_SORT = {
                     "$sort" => {
                       timestamp: 1
                     }
                   }.freeze

    FINAL_SORT = {
                   "$sort" => {
                     BUCKET => 1
                   }
                 }.freeze

    POWER_PROJECT = {
                 "$project" => {
                    BUCKET => "$#{BUCKET}",
                    AVG =>  "$#{AVG}"
                 }
               }.freeze
    
    ENERGY_PROJECT = {
                 "$project" => {
                    BUCKET => "$#{BUCKET}",
                    FIRST =>  "$#{FIRST}",
                    LAST =>  "$#{LAST}"
                 }
               }.freeze

    GROUPS = begin
               groups = {}
               SELECTORS.each do |duration, selector|
                 if [:year, :month].include? duration
                   group = {
                     "$group" => {
                       BUCKET => { "$first"  => "$timestamp" },
                       FIRST => { "$first" => "$#{ENERGY}" },
                       LAST => { "$last"  => "$#{ENERGY}" }
                     }
                   }
                 else
                   group = {
                     "$group" => {
                       BUCKET => { "$first"  => "$timestamp" },
                       AVG => { "$avg"  => "$#{POWER}" }
                     }
                   }
                 end
                 formats = group['$group'][:_id] = {}
                 selector.each do |format|
                   formats["#{format}ly"] = "$#{format}ly"
                 end
                 groups[duration] = group
               end
               groups.freeze
             end

    def query_value(profile, timestamp)
      Reading::Continuous.where(:timestamp.gte => timestamp, source: profile).only('timestamp', 'source', POWER).order_by(timestamp: 1).limit(1).first
    end

    def query_range(profile, interval)
      case interval.duration
      when :year, :month
        energy_query_range(profile, interval)
      when :day, :hour, :second
        power_query_range(profile, interval)
      else
        raise ArgumentError.new "unknown duration #{interval.duration}"
      end
    end

    def energy_query_range(profile, interval)
      now = Time.current.utc
      adjusted = interval.to_as_utc_time < now ? interval.to_as_utc_time + 1.day : now
      raw = do_query_range(profile, interval.from_as_utc_time, adjusted, interval.duration, ENERGY).to_a
      if current = raw.first
        raw.to_a[1..-1].each do |item|
          current[SUM] = item[FIRST] - current[FIRST]
          current = item
        end
      end
      if adjusted == now
        last = raw.last
        last[SUM] = last[LAST] - last[FIRST]
        raw
      else
        raw[0..-2]
      end
    end

    def power_query_range(profile, interval)
      now = Time.current.utc
      adjusted = interval.to_as_utc_time < now ? interval.to_as_utc_time + 1.day : now
      do_query_range(profile, interval.from_as_utc_time, adjusted, interval.duration, POWER).to_a
    end

    def do_query_range(profile, from, to, duration, units)
      # start pipe
      pipe = []

      # sort
      pipe << INITIAL_SORT

      # match
      match = {
                "$match" => {
                  timestamp: {
                    "$gte"  => from.to_datetime,
                    "$lt"  => to.to_datetime
                  },
                  source: { "$in" => [profile] }
                }
              }
      pipe << match




      # project
      project = {
                  "$project" => {
                    timestamp: 1
                  }
                }

      # mongodb can give you the year, month, day_of_month, hour, minutes and
      # seconds of a timestamp. the timestamps stored in mongodb are in UTC
      # (i.e. have no timeone).
      # receiving 'from' and 'to' which are coming from original timezone based
      # timestamps like a year in
      # Greenland: 2015-01-01 03:00:00 UTC to 2016-01-01 03:00:00 UTC
      # or a month in
      # Berlin: 2010-04-30 22:00:00 UTC to 2010-05-01 22:00:00 UTC
      #
      # moving the timestamp to the beginning of the nearest days gives back
      # UTC timestamps which matches the year, month, day_of_month, hour,
      # minutes and seconds of the original timestamp with timezone
      #
      # Greenland: 2015-01-01 00:00:00 UTC to 2016-01-01 00:00:00 UTC
      # Berlin: 2010-05-01 00:00:00 UTC to 2010-06-01 00:00:00 UTC
      next_day = (from + 1.day).beginning_of_day - from
      previous_day = from - from.beginning_of_day
      if next_day >= previous_day
        offset = -1000 * previous_day
      else
        offset = 1000 * next_day
      end
      
      selector = SELECTORS[duration]
      project["$project"][units] = 1
      formats = {}
      selector.each do |format|
        if format == 'fifteen'
          formats['fifteenly'] = { '$floor' => { "$divide" => [{"$minute"=>{"$add"=>["$timestamp", 3600000.0]}}, 15] }}
        else
          formats["#{format}ly"] = { "$#{format}" => { "$add" => [ "$timestamp", offset ] } }
        end
      end
      project["$project"].merge!(formats)
      pipe << project



      # group
      pipe << GROUPS[duration]
      
      # project
      if units == ENERGY
        pipe << ENERGY_PROJECT
      else
        pipe << POWER_PROJECT
      end

      # sort
      pipe << FINAL_SORT

      Reading::Continuous.collection.aggregate(pipe)
    end





  end
end
