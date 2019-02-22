require_relative '../services'

class Services::ReadingService

  include Import['services.datasource.discovergy.single_reading']

  def get(register, date, precision: 600, fetch: true, create: true)
    # first check whether we already have this reading
    readings = register.readings.between((date.to_time - precision/2).to_date, (date.to_time + precision/2).to_date)
    if readings.any?
      readings
    elsif !register.meter.datasource.nil? && fetch
      case register.meter.datasource.to_sym
      when :discovergy
        reading = single_reading.single(register, date)
        if reading.nil?
          return nil
        end
        value = reading.values.first.round
        attrs = {
          raw_value: value,
          unit: :watt_hour,
          reason: :regular_reading,
          read_by: :buzzn,
          quality: :read_out,
          source: :smart,
          status: :z86,
          date: date,
        }
        if create
          [register.readings.create(attrs)]
        else
          [register.readings.build(attrs)]
        end
      when :standard_profile
        nil
      end
    else
      nil
    end
  end

end
