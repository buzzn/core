require_relative '../discovergy'
require_relative '../../../types/discovergy'

class Services::Datasource::Discovergy::Meters

  include Import['services.datasource.discovergy.api']
  include Types::Discovergy

  def all
    meters = process(Meters::Get.new)
    meters.each_with_object({}) do |meter, map|
      map[meter.serialNumber] = meter
    end
  end

  def connected?(meter_or_serial)
    meter =
      case meter_or_serial
      when ::Meter::Base then meter_or_serial
      else
        ::Meter::Real.new(product_serialnumber: meter_or_serial)
      end
    !process(LastReading::Get.new(meter: meter, fields: [:power])).nil?
  end

  def easymeters
    filter('EASYMETER')
  end

  def virtualmeters
    filter('VIRTUAL')
  end

  def meter_to_virtual_map
    virtualmeters.each_with_object({}) do |entry, map|
      collect_entries(entry[1], map)
    end
  end

  private

  def collect_entries(meter, map)
    meters = process(VirtualMeter::Get.new(meter: meter))
    meters.each do |m|
      list = (map[m.serialNumber] ||= [])
      list << meter
    end
  end

  def filter(type)
    all.select { |serial, meter| meter.type == type }
  end

  def process(query)
    api.request(query)
  end

end
