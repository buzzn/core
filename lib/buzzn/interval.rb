module Buzzn

  class Interval

    attr_reader :from, :to, :resolution

    class << self
      private :new
    end

    def initialize(from, to)
      @from = from
      @to = to
      @resolution = _resolution
    end

    def year?
      timespan = self.to - self.from
      timespan <= 31622401 && timespan > 2678401
    end

    def month?
      timespan = self.to - self.from
      timespan <= 2678401 && timespan > 86401
    end

    def day?
      timespan = self.to - self.from
      timespan <= 86401 && timespan > 3601
    end

    def hour?
      timespan = self.to - self.from
      timespan <= 3601 && timespan > 0
    end

    def _resolution
      self.hour? ? :hour : (
        self.day? ? :day : (
          self.month? ? :month : (
            self.year? ? :year : nil
          )
        )
      )
    end
    private :_resolution

    class << self
      private :new

      def create_time_from_timestamp(timestamp)
        Time.at(timestamp.to_i/1000).in_time_zone
      end

      def year(timestamp)
        if timestamp.is_a?(Time)
          new(timestamp.in_time_zone.beginning_of_year,
            (timestamp.in_time_zone.beginning_of_year + 365.days))
        else
          new(self.create_time_from_timestamp(timestamp).beginning_of_year,
            (self.create_time_from_timestamp(timestamp).beginning_of_year + 365.days))
        end
      end

      def month(timestamp)
        if timestamp.is_a?(Time)
          new(timestamp.in_time_zone.beginning_of_month,
            (timestamp.in_time_zone.end_of_month + 1.second))
        else
          new(self.create_time_from_timestamp(timestamp).beginning_of_month,
            (self.create_time_from_timestamp(timestamp).end_of_month + 1.second))
        end
      end

      def day(timestamp)
        if timestamp.is_a?(Time)
          new(timestamp.in_time_zone.beginning_of_day,
            (timestamp.in_time_zone.end_of_day + 1.second))
        else
          new(self.create_time_from_timestamp(timestamp).beginning_of_day,
            (self.create_time_from_timestamp(timestamp).end_of_day + 1.second))
        end
      end

      def hour(timestamp)
        if timestamp.is_a?(Time)
          new(timestamp.in_time_zone.beginning_of_hour,
            (timestamp.in_time_zone.end_of_hour))
        else
          new(self.create_time_from_timestamp(timestamp).beginning_of_hour,
            (self.create_time_from_timestamp(timestamp).end_of_hour))
        end
      end
    end
  end
end

