require_relative '../discovergy'
require_relative '../../types/datasource'

module Builders::Discovergy
  class TickerBuilder < AbstractBuilder

    BROKEN_REGISTER_RESPONSE = -1

    option :unit, Current::Unit
    option :register

    def build(response)
      case register
      when Register::Real
        build_easymeter(response)
      else
        raise "unknown register type: #{register.class}"
      end
    end

    private

    def build_easymeter(response)
      Current.new(time: response['time'],
                  unit: unit,
                  value: to_value(response, register).round,
                  register: register)
    end

    def to_value(response, register)
      return BROKEN_REGISTER_RESPONSE unless response
      case unit
      when :Wh
        to_watt_hour(response, register)
      when :W
        to_watt(response, register)
      else
        raise "unknown unit: #{unit}"
      end
    end

  end
end
