module Buzzn

  class Interval

    attr_reader :from, :to, :period, :resolution

    def initialize(from = nil, to = from)
      @from = from
      @to = to
      @resolution = _resolution
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
      self.live? ? :live : (
        self.hour? ? :hour_to_minutes : (
          self.day? ? :day_to_minutes : (
            self.month? ? :month_to_days : (
              self.year? ? :year_to_months : nil
            )
          )
        )
      )
    end
    private :_resolution

    class << self
      private :new

      def create_time_from_timestamp(timestamp)
        Time.at(timestamp.to_i/1000)
      end

      def live
        new
      end

      def year(timestamp)
        if timestamp.is_a?(Time)
          new(
            timestamp.beginning_of_year,
            timestamp.next_year
          )
        else
          new(
            self.create_time_from_timestamp(timestamp).beginning_of_year,
            self.create_time_from_timestamp(timestamp).next_year
          )
        end
      end

      def month(timestamp)
        if timestamp.is_a?(Time)
          new(
            timestamp.beginning_of_month,
            timestamp.next_month
          )
        else
          new(
            self.create_time_from_timestamp(timestamp).beginning_of_month,
            self.create_time_from_timestamp(timestamp).next_month
          )
        end
      end

      def day(timestamp)
        if timestamp.is_a?(Time)
          new(
            timestamp.beginning_of_day,
            timestamp.beginning_of_day + 1.day
          )
        else
          new(
            self.create_time_from_timestamp(timestamp).beginning_of_day,
            self.create_time_from_timestamp(timestamp).beginning_of_day + 1.day
          )
        end
      end

      def hour(timestamp)
        if timestamp.is_a?(Time)
          new(
            timestamp.beginning_of_hour,
            timestamp.beginning_of_hour + 1.day
          )
        else
          new(
            self.create_time_from_timestamp(timestamp).beginning_of_hour,
            self.create_time_from_timestamp(timestamp).beginning_of_hour + 1.day
            )
        end
      end
    end
  end
end
