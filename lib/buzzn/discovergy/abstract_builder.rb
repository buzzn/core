require_relative '../discovergy'
require_relative '../types/datasource'

class Discovergy::AbstractBuilder

  extend Dry::Initializer
  include Types::Datasource

  protected

  def to_watt_hour(response, register)
    values = response['values']
    value =
      if register.meter.two_way_meter?
        two_way_meter_value(values, register)
      else
        values['energy']
      end
    # ENERGY/ENERGYOUT resolution is 10^-10 kWh
    value / 10_000_000.0
  end

  def two_way_meter_value(values, register)
    case register.direction
    when 'output'
      values['energyOut']
    when 'input'
      values['energy']
    else
      raise "unknown direction: #{register.direction}"
    end
  end

  def to_watt(response, register)
    val = to_watt_raw(response)
    if register.meter.one_way_meter?
      val < 0 ? 0 : val # sometime discovergy delivers negative values: 0 them
    else
      adjust(val, register)
    end
  end

  private

  def adjust(val, register)
    case register
    when Register::Output
      val > 0 ? 0 : -val
    when Register::Input
      val < 0 ? 0 : val
    else
      raise "Not implemented for #{register}"
    end
  end

  def to_watt_raw(response)
    # power in 10^-3 W
    response.nil? ? 0 : response['values']['power'] / 1000
  end

end
