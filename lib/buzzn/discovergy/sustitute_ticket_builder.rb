require_relative 'abstract_registers_builder'

class Discovergy::SubstituteBuilder < Discovergy::AbstractRegistersBuilder

  option :unit, Current::Unit
  option :register

  def build(response)
    to_value = value_method(unit)
    substitute = 0
    time = 0
    response.each do |id, values|
      register = map[id]
      # We skip meters we don't know about to prevent an error. See
      # https://github.com/buzzn/core/pull/1338/files for details.
      next unless register
      value = to_value.call(register, values)
      substitute = add(substitute, value, register)
      time = [value['time'], time].max
    end
    Current.new(time: time,
                unit: unit,
                value: substitute,
                register: register)
  end

  private

  def add(substitute, value, register)
    if register.label.consumption?
      substitute - value
    elsif register.label.production?
      substitute + value
    elsif label.grid_feeding?
      substitute - value
    elsif label.grid_consumption?
      substitute + value
    else
      raise "can not handle #{register.class}"
    end
  end

  def value_method
    case unit
    when :Wh
      method(:to_watt_hour)
    when :W
      method(:to_watt)
    else
      raise "unknown unit: #{unit}"
    end
  end

end
