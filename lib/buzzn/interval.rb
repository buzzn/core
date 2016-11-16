module Buzzn

  class Interval

    attr_reader :from, :to, :type

    def initialize(from = nil, to = from)
      @from = from
      @to = to
      @type = from.class
    end

    class << self
      private :new

      def live
        new
      end

      def year(timestamp)
        new(Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_year.to_date,
            (Time.at(timestamp.to_i/1000).in_time_zone.end_of_year + 1.second).to_date)
      end

      def month(timestamp)
        new(Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_month.to_date,
            (Time.at(timestamp.to_i/1000).in_time_zone.end_of_month + 1.second).to_date)
      end
        
      def day(timestamp)
        new(Time.at(timestamp.to_i/1000).in_time_zone.to_date)
      end

      def hour(timestamp)
        new((Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_hour).to_i*1000,
            (Time.at(timestamp.to_i/1000).in_time_zone.end_of_hour).to_i*1000)
      end
    end
  end
end

