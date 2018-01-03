require_relative '../discovergy'
require_relative '../../../types/discovergy'
require_relative '../../../discovergy'

class Services::Datasource::Discovergy::LastReading

  include Import['services.datasource.discovergy.api']

  def energy(register)
    process(register, :Wh, false, :energy, :energyOut)
  end

  def power(register)
    process(register, :W, false, :power)
  end

  def power_collection(group)
    if meter = Meter::Discovergy.where(group: group).first
      query = Types::Discovergy::LastReading::Get.new(meter: meter,
                                                      fields: [:power],
                                                      each:   true)
      builder = Discovergy::BubbleBuilder.new(registers: meter.group.registers.consumption_production)
      api.request(query, builder)
    end
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
