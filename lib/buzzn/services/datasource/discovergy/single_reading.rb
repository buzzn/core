require_relative '../discovergy'
require_relative '../../../types/discovergy'
require_relative '../../../builders/discovergy'

class Services::Datasource::Discovergy::SingleReading

  include Import['services.datasource.discovergy.api']

  def all(group, date)
    meter = Meter::Discovergy.find_by(group: group)
    return unless meter
    # get a bunch of values around the requested one, in case those exactly on the date aren't
    from  = (date - 1.hours).to_i * 1_000 # Discovergy requires an UNIX timestamp in ms
    to    = (date + 1.hours).to_i * 1_000
    query = Types::Discovergy::Readings::Get.new(meter: meter,
                                                 fields: [:energy, :energyOut],
                                                 each:   true,
                                                 from:   from,
                                                 to:     to,
                                                 resolution: :fifteen_minutes)
    builder = Builders::Discovergy::SingleReadingsBuilder.new(registers: group.registers)
    api.request(query, builder)
  end
end
