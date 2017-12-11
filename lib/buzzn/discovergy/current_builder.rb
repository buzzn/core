require_relative '../discovergy'
require_relative '../types/datasource'

class Discovergy::CurrentBuilder
  extend Dry::Initializer
  include Types::Datasource

  option :unit, Current::Unit
  option :register

  def build(response)
    case register
    when Register::Real
      build_easymeter(response)
    else
      raise "unknown regiter type: #{register.class}"
    end
  end

  private

  def build_easymeter(response)
    Current.new(time: response['time'],
                unit: unit,
                value: to_value(response),
                register: register)
  end

  def to_value(response)
    return -1 unless response
    case unit
    when :Wh
      to_watt_hour(response)
    when :W
      to_watt(response)
    else
      raise "unknown unit: #{unit}"
    end
  end

  def to_watt(response)
    # POWER(X) is the (phase) power in 10^-3 W
    response['values']['power'] / 1000
  end

  def to_watt_hour(response)
    values = response['values']
    value =
      if register.meter.two_way_meter?
        two_way_meter_value(values)
      else
        values['energy']
      end
    # ENERGY/ENERGYOUT resolution is 10^-10 kWh
    value / 10000000
  end

  def two_way_meter_value(values)
    case register.direction
    when 'output'
      values['energyOut']
    when 'input'
      values['energy']
    else
      raise "unknown direction: #{register.direction}"
    end
  end
end
