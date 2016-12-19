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

    def from_as_millis
      (@from * 1000).to_i
    end

    def to_as_millis
      (@to * 1000).to_i
    end

    def from_as_time
      Time.at(@from).utc
    end

    def to_as_time
      Time.at(@to).utc
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

      def year(timestamp = Time.current)
        if timestamp.is_a?(Time)
          new(
            timestamp.beginning_of_year.to_f,
            timestamp.beginning_of_year.next_year.to_f
          )
        else
          raise ArgumentError.new('need a Time object')
        end
      end

      def month(timestamp = Time.current)
        if timestamp.is_a?(Time)
          new(
            timestamp.beginning_of_month.to_f,
            timestamp.beginning_of_month.next_month.to_f
          )
        else
          raise ArgumentError.new('need a Time object')
        end
      end

      def day(timestamp = Time.current)
        if timestamp.is_a?(Time)
          new(
            timestamp.beginning_of_day.to_f,
            (timestamp.beginning_of_day + 1.day).to_f
          )
        else
          raise ArgumentError.new('need a Time object')
        end
      end

      def hour(timestamp = Time.current)
        if timestamp.is_a?(Time)
          new(
            timestamp.beginning_of_hour.to_f,
            (timestamp.beginning_of_hour + 1.hour).to_f
          )
        else
          raise ArgumentError.new('need a Time object')
        end
      end
    end
  end
end

