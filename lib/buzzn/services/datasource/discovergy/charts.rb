require_relative '../discovergy'
require_relative '../../../types/discovergy'
require_relative '../../../builders/discovergy'

class Services::Datasource::Discovergy::Charts

  include Import['services.datasource.discovergy.api']

  def daily(group)
    if meter = Meter::Discovergy.where(group: group).first
      query = Types::Discovergy::Readings::Get.new(meter: meter,
                                                   fields: [:energy, :energyOut],
                                                   each:   true,
                                                   from:   beginning_of_today,
                                                   resolution: :fifteen_minutes )
      registers = group.registers.grid_production_consumption.includes(:meter)
      builder = Builders::Discovergy::DailyChartsBuilder.new(registers: registers)
      api.request(query, builder)
    end
  end

  private

  def external_ids(registers)
    Meter::Base.where(id: registers.collect(:meter_id)).collect do |meter|
      "EASYMETER_#{meter.product_serialnumber}"
    end
  end

  def beginning_of_today
    today = Buzzn::Utils::Chronos.today.to_time(:utc)
    today -= 1.hour # Berlin Timezone
    today -= 15.minutes # using 'fifteen_minutes' intervals
    (1000 * today.to_f).to_i
  end

end
