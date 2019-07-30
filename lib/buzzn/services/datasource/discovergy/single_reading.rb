require_relative '../discovergy'
require_relative '../../../types/discovergy'
require_relative '../../../builders/discovergy'

class Services::Datasource::Discovergy::SingleReading

  include Import['services.datasource.discovergy.api']

  def all(group, date)
    meter = Meter::Discovergy.find_by(group: group)
    return unless meter
    api.request(
      query(meter, date),
      builder(group)
    )
  end

  private

  def query(meter, date)
    params = {
      meter:  meter,
      fields: [:energy, :energyOut],
      each:   true,
      # get a bunch of values around the requested date, in case those exactly on the date aren't available
      from:   as_unix_timestamp_ms(date - 1.hours),
      to:     as_unix_timestamp_ms(date + 1.hours),
      resolution: :fifteen_minutes
    }
    Types::Discovergy::Readings::Get.new(params)
  end

  def builder(group)
    consumption_registers = group.registers.select { |register| register.label.consumption? }
    Builders::Discovergy::SingleReadingsBuilder.new(registers: consumption_registers)
  end

  # Discovergy requires an UNIX timestamp in ms
  def as_unix_timestamp_ms(date)
    date.to_i * 1_000
  end

end
