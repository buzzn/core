require_relative '../discovergy'
require_relative '../types/datasource'

class Discovergy::AbstractBuilder

  extend Dry::Initializer
  include Types::Datasource

  protected

  def to_watt_hour(response, register)
    values = response['values']
    value =
      if one_way_meter?(register)
        values['energy']
      else
        two_way_meter_value(values, register)
      end
    # ENERGY/ENERGYOUT resolution is 10^-10 kWh
    value / 10_000_000.0
  end

  def two_way_meter_value(values, register)
    if production?(register)
      values['energy']
    elsif consumption?(register)
      values['energyOut']
    else
      raise "unknown direction: #{register.direction}"
    end
  end

  def to_watt(response, register)
    val = to_watt_raw(response)
    if one_way_meter?(register)
      val < 0 ? 0 : val # sometime discovergy delivers negative values: 0 them
    else
      adjust(val, register)
    end
  end

  private

  def one_way_meter?(register)
    register.meter.registers.size == 1
  end

  def production?(register)
    register.label.production? || register.grid_consumption?
  end

  def consumption?(register)
    register.label.consumption? || register.grid_feeding?
  end

  def adjust(val, register)
    if consumption?(register)
      val > 0 ? 0 : -val
    elsif production?(register)
      val < 0 ? 0 : val
    else
      raise "Not implemented for #{register} with label #{register.label}"
    end
  end

  def to_watt_raw(response)
    # power in 10^-3 W
    response.nil? ? 0 : response['values']['power'] / 1000.0
  end

end
