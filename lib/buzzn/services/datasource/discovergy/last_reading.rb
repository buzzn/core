require_relative '../discovergy'
require_relative '../../../types/discovergy'
require_relative '../../../builders/discovergy'

class Services::Datasource::Discovergy::LastReading

  include Import['services.datasource.discovergy.api']

  def energy(register)
    process(register, :Wh, :energy, :energyOut)
  end

  def power(register)
    process(register, :W, :power)
  end

  def power_collection(group)
    registers = group.registers.consumption_production.includes(:meter)
    builder = Builders::Discovergy::BubbleBuilder.new(registers: registers)
    collection(group, builder, :power)
  end

  private

  def collection(group, builder, *fields)
    if meter = Meter::Discovergy.where(group: group).first
      api_call(meter, fields, true, builder)
    end
  end

  def process(register, unit, *fields)
    case register
    when Register::Real
      builder = Builders::Discovergy::TicketBuilder.new(register: register, unit: unit)
      api_call(register.meter, fields, false, builder)
    when Register::Substitute
      builder = Builders::Discovergy::TicketBuilder.new(register: register, unit: unit)
      api_call(meter, fields, true, builder)
    else
      raise "unknown regiter type: #{register.class}"
    end
  end

  def api_call(meter, fields, each, builder)
    query = Types::Discovergy::LastReading::Get.new(meter: meter,
                                                    fields: fields,
                                                    each:   each)
    api.request(query, builder)
  end

end
