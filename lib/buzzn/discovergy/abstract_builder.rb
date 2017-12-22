require_relative '../discovergy'
require_relative '../types/datasource'

class Discovergy::AbstractBuilder
  extend Dry::Initializer
  include Types::Datasource

  protected

  def to_watt(response, register)
    val = to_watt_raw(response)
    if register.meter.one_way_meter?
      val
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
