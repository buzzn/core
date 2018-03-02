require_relative 'abstract_registers_builder'
require_relative 'substitute_calculator'

module Builders::Discovergy
  class SubstituteTickerBuilder < AbstractRegistersBuilder

    option :unit, Current::Unit
    option :register

    def build(response)
      substitute = SubstituteCalculator.new(self)
      response.each do |id, values|
        registers = map[id]
        next unless registers
        registers.each do |register|
          substitute.process(values, register)
        end
      end
      Current.new(time: substitute.time,
                  unit: unit,
                  value: substitute.value,
                  register: register)
    end

  end
end
