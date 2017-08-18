module Buzzn
  module Math
    class Number

      ORDERS = [:micro, :milli, :normal, :kilo, :mega]
      UNITS = [:watt, :watt_hour, :cubic_meter]

      class << self
        UNITS.each do |unit|
         # binding.pry
          define_method unit do |val, order = :normal|
            new(val, unit, order)
          end
        end
      end

      attr_reader :value, :unit, :order
      def initialize(value, unit, order)
        @value = value
        @unit = unit
        unless @order = ORDERS.detect { |s| s == order }
          raise 'unknown order'
        end
      end

      ORDERS.each do |order|
        define_method order do
          to_order(order)
        end
      end

      def exp(order)  
        ORDERS.index(order) -
          ORDERS.index(@order)
      end

      def to_order(order)
        if exp = exp(order)
          self.class.new(@value * 1000.0 ** exp, @unit, order)
        else
          self
        end
      end

      def +(number)
        check_unit(number)
        self.class.new(@value + number.value * 1000.0 ** exp(number.order),
                       @unit, @order)
      end
      alias :add :+

      def -(number)
        check_unit(number)
        self.class.new(@value - number.value * 1000.0 ** exp(number.order),
                       @unit, @order)
      end
      alias :sub :-

      def check_unit(number)
        raise 'unit mismatch' if number.unit != @unit
      end
    end
  end
end
