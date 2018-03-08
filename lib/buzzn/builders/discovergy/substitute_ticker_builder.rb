require_relative 'abstract_registers_builder'
require_relative 'substitute_calculator'

module Builders::Discovergy
  class SubstituteTickerBuilder < AbstractRegistersBuilder

    option :unit, Current::Unit
    option :register

    def build(response)
      calculator = SubstituteCalculator.new(self)
      response.each do |id, values|
        registers = map[id]
        next unless registers
        registers.each do |register|
          calculator.process(values, register)
        end
      end
      Current.new(time: calculator.time,
                  unit: unit,
                  value: calculator.value(register),
                  register: register)
    end

  end
end
