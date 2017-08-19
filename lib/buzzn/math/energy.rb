module Buzzn
  module Math
    class Energy < Number

      def self.new(value, order = :normal)
        super(value, :watt_hour, order)
      end

      def self.zero
        @zero ||= new(0)
      end
    end
    class Number
      def self.watt_hour(val, order = :normal)
        Energy.new(val, order)
      end
    end
  end
end
