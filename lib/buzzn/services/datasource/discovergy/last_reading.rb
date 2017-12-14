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

  def bubbles(group)
    if meter = Meter::Discovergy.where(group: group).first
      query = Types::Discovergy::LastReading::Get.new(meter: meter,
                                                      fields: [:power],
                                                      each:   true)
      builder = Discovergy::BubbleBuilder.new(meters: meter.group.meters)
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
