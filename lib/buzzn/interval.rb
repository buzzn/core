module Buzzn

  class Interval

    attr_reader :from, :to, :duration

    class << self
      private :new
    end

    def initialize(from, to)
      @from = from
      @to = to
      @duration = _duration
    end

    def respond_to?(method)
      super || private_methods.include?(:"_#{method}")
    end

    def method_missing(method, *args)
      if private_methods.include? :"_#{method}"
        @duration == method.to_s[0..-2].to_sym
      else
        super
      end
    end

    private
    def _year?
      timespan = self.to - self.from
      timespan <= 31622401 && timespan > 2678401
    end

    def _month?
      timespan = self.to - self.from
      timespan <= 2678401 && timespan > 86401
    end

    def _day?
      timespan = self.to - self.from
      timespan <= 86401 && timespan > 3601
    end

    def _hour?
      timespan = self.to - self.from
      timespan <= 3601 && timespan > 0
    end

    def _duration
      _hour? ? :hour : (
        _day? ? :day : (
          _month? ? :month : (
            _year? ? :year : nil
          )
        )
      )
    end

    class << self
      private :new

      def create_time_from_timestamp(timestamp)
        Time.at(timestamp.to_i/1000).in_time_zone
      end

      def year(timestamp = Time.current)
        if timestamp.is_a?(Time)
          new(
            timestamp.beginning_of_year,
            timestamp.beginning_of_year.next_year
          )
        else
          new(
            self.create_time_from_timestamp(timestamp).beginning_of_year,
            self.create_time_from_timestamp(timestamp).beginning_of_year.next_year
          )
        end
      end

      def month(timestamp = Time.current)
        if timestamp.is_a?(Time)
          new(
            timestamp.beginning_of_month,
            timestamp.beginning_of_month.next_month
          )
        else
          new(
            self.create_time_from_timestamp(timestamp).beginning_of_month,
            self.create_time_from_timestamp(timestamp).beginning_of_month.next_month
          )
        end
      end

      def day(timestamp = Time.current)
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

      def hour(timestamp = Time.current)
        if timestamp.is_a?(Time)
          new(
            timestamp.beginning_of_hour,
            timestamp.beginning_of_hour + 1.hour
          )
        else
          new(
            self.create_time_from_timestamp(timestamp).beginning_of_hour,
            self.create_time_from_timestamp(timestamp).beginning_of_hour + 1.hour
            )
        end
      end
    end
  end
end

