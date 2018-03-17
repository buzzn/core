require_relative 'abstract_registers_builder'

module Builders::Discovergy
  class SingleReadingsBuilder < AbstractRegistersBuilder

    def build(response)
      response.each.with_object({}) do |(meter_id, data), hash|
        registers       = map[meter_id]
        hash[meter_id]  = registers.map { |register| to_watt_hour(data.first, register) }
      end
    end

  end
end
