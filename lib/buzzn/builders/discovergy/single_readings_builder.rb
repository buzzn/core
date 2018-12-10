require_relative 'abstract_registers_builder'

module Builders::Discovergy
  class SingleReadingsBuilder < AbstractRegistersBuilder

    # whether it's a virtual meter/register
    option :virtual

    def build(response)
      if virtual
        smart_registers = registers.to_a.select { |register| register.meter.datasource.to_sym == :discovergy }
        smart_registers.each.with_object({}) do |register, hash|
          reading = find_reading(response, register)
          hash[register.id] = reading if reading
        end
      else
        register = registers.first
        reading = response.first
        unless reading
          Buzzn::Logger.root.error("No reading for #{register}")
          return
        end
        { register.id => to_watt_hour(reading, register) }
      end
    end

    private

    def find_reading(response, register)
      # FIXME: use register.meter.broker.external_id.
      register_identifier = "EASYMETER_#{register.meter.product_serialnumber}"
      all_readings = response[register_identifier]
      reading = all_readings.first
      unless reading
        Buzzn::Logger.root.error("No reading for #{register} #{register_identifier}")
        return
      end
      to_watt_hour(reading, register)
    end

  end
end
