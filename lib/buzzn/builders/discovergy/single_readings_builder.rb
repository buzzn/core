require_relative 'abstract_registers_builder'

module Builders::Discovergy
  class SingleReadingsBuilder < AbstractRegistersBuilder

    def build(response)
      smart_registers = registers.to_a.select { |register| register.meter.datasource == :discovergy }
      smart_registers.each.with_object({}) do |register, hash|
        reading = find_reading(response, register)
        hash[register.id] = reading if reading
      end
    end

    private

    def find_reading(response, register)
      # FIXME: use register.meter.broker.external_id.
      register_identifier = "EASYMETER_#{register.meter.product_serialnumber}"
      all_readings = response[register_identifier]
      reading = all_readings.first
      unless reading
        Buzzn::Logger.root.error("No reading for #{register} #{register_identifier}, returning 0")
        return
      end
      to_watt_hour(reading, register)
    end

  end
end
