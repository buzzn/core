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
    energy = values['energy']
    energy_out = values['energyOut']
    # TODO need to handle two-direction-meters
    value =
      case register.direction
      when 'output'
        energy
      when 'input'
        energy
      else
        raise "unknown direction: #{register.direction}"
      end
    # ENERGY/ENERGYOUT resolution is 10^-10 kWh
    value / 10000000
  end
end
