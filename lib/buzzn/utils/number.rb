# coding: utf-8
module Buzzn
  module Utils
    class Number

      ORDERS = { micro: 'μ', milli: 'm', nil => '', kilo: 'k', mega: 'M'}
      INTERNAL_HALF_ORDER_SIZE = ORDERS.size / 2
      UNITS = {}

      attr_reader :value, :unit

      class << self
        def create(clazz, unit, short)
          UNITS[unit] = short
          clazz.define_singleton_method :new do |val|
            super(val, unit)
          end
          clazz.const_set(:ZERO, clazz.zero)
          define_singleton_method unit do |val|
            clazz.new val
          end
        end

        def zero
          @zero ||= new(0)
        end
      end

      def initialize(value, unit)
        @value = value.to_f
        @unit = unit
      end

      def +(number)
        check_unit(number)
        self.class.new(@value + number.value)
      end
      alias :add :+

      def -(number)
        check_unit(number)
        self.class.new(@value - number.value)
      end
      alias :sub :-

      def respond_to?(method)
        @value.respond_to?(method) || super
      end

      def method_missing(method, *args)
        if @value.respond_to? method
          self.class.new(@value.send(method, *args))
        else
          super
        end
      end

      def /(scale)
        case scale
        when self.class
          @value / scale.value
        else
          self.class.new(@value / scale)
        end
      end
      alias :div :/

      def check_unit(number)
        raise "not a #{self.class}: #{number.inspect}" unless number.is_a?(self.class)
        raise 'unit mismatch' if number.unit != @unit
      end

      [:>, :<, :==, :!=, :<=, :>=, :<=>].each do |op|
        define_method op do |other|
          raise 'unit mismatch' if other.unit != @unit
          @value.send(op, other.value)
        end
      end
      alias :eql? :==

      def to_s(order = nil)
        ord = INTERNAL_HALF_ORDER_SIZE - ORDERS.keys.index(order)
        #binding.pry
        val = @value * 1000 ** ord
        "#{val} #{ORDERS[order]}#{UNITS[unit]}"
      end
    end
  end
end
require_relative 'energy'
