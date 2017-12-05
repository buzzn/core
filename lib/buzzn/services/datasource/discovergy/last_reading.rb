require_relative '../discovergy'
require_relative '../../../types/discovergy'
require_relative '../../../discovergy'

class Services::Datasource::Discovergy::LastReading

  include Import['service.datasource.discovergy.api']

  def energy(register)
    process(register, :Wh, false, :energy, :energyOut)
  end

  def power(register)
    process(register, :W, false, :power)
  end

  def bubbles(register)
    unless register.is_a?(Register::Virtual)
      raise "must be Register::Virtual: #{register}"
    end
    process(register, :W, true, :power)
  end

  private

  def process(register, unit, each, *fields)
    query = Types::Discovergy::LastReading::Get.new(meter: register.meter,
                                                    fields: fields,
                                                    each:   each)
    builder = Discovergy::CurrentBuilder.new(register: register, unit: unit)
    api.request(query, builder)
  end
end
