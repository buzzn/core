module Buzzn

  class Interval

    attr_reader :from, :to, :type

    def initialize(from = nil, to = from)
      @from = from
      @to = to
      @type = from.class
    end

    def live?
      @from.nil?
    end

    def year?
      timespan = self.to - self.from
      timespan <= 31622401 && timespan > 2678401
    end

    def month?
      timespan = self.to - self.from
      timespan <= 2678401 && timespan > 87301
    end

    def day?
      timespan = self.to - self.from
      timespan <= 87301 && timespan > 3601
    end

    def hour?
      timespan = self.to - self.from
      timespan <= 3601 && timespan > 0
    end

    class << self
      private :new

      def live
        new
      end

      def year(timestamp)
        new(Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_year,
            (Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_year + 365.days))
      end

      def month(timestamp)
        new(Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_month,
            (Time.at(timestamp.to_i/1000).in_time_zone.end_of_month + 1.second))
      end

      def day(timestamp)
        new(Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_day,
            (Time.at(timestamp.to_i/1000).in_time_zone.end_of_day + 1.second))
      end

      def hour(timestamp)
        new((Time.at(timestamp.to_i/1000).in_time_zone.beginning_of_hour),
            (Time.at(timestamp.to_i/1000).in_time_zone.end_of_hour))
      end
    end
  end
end

