require_relative '../discovergy'
require_relative '../../types/datasource'

class Builders::Discovergy::AbstractBuilder

  extend Dry::Initializer
  include Types::Datasource

  protected

  def logger
    @logger ||= Buzzn::Logger.new(self)
  end

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
      values['energyOut']
    elsif consumption?(register)
      values['energy']
    else
      raise "unknown direction: #{register.direction}"
    end
  end

  def to_watt(response, register)
    val = to_watt_raw(response)
    if one_way_meter?(register)
      [0, val].max # sometime discovergy delivers negative values: 0 them
    else
      adjust(val, register)
    end
  end

  private

  def one_way_meter?(register)
    register.meter.one_way_meter?
  end

  def production?(register)
    register.production? || register.meta.grid_feeding?
  end

  def consumption?(register)
    register.consumption?|| register.meta.grid_consumption?
  end

  def adjust(val, register)
    if consumption?(register)
      [0, val].max
    elsif production?(register)
      [0, -val].max
    else
      raise "Not implemented for #{register} with label #{register.label}"
    end
  end

  def to_watt_raw(response)
    # power in 10^-3 W
    response.nil? ? 0 : response['values']['power'] / 1000.0
  end

end
