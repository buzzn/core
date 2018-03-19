require_relative 'abstract_registers_builder'

module Builders::Discovergy
  class SingleReadingsBuilder < AbstractRegistersBuilder

    def build(response)
      registers.each.with_object({}) do |register, hash|
        hash[register.id] = find_reading(response, register)
      end
    end

    private

    def find_reading(response, register)
      register_identifier = "EASYMETER_#{register.meter.product_serialnumber}"
      all_readings = response[register_identifier]
      to_watt_hour(all_readings.first, register)
    end
  end
end
