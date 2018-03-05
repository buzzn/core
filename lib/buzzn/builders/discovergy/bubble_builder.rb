require_relative 'abstract_registers_builder'
require_relative 'substitute_calculator'

module Builders::Discovergy
  class BubbleBuilder < AbstractRegistersBuilder

    def unit
      :W
    end

    def build(response)
      calculator = SubstituteCalculator.new(self)
      result = response.collect do |id, values|
        registers = map[id]
        # Unfortunately our and Discovergy's list of meters can get out of sync as of now.
        # We skip meters we don't know about to prevent an error. See
        # https://github.com/buzzn/core/pull/1338/files for details.
        next unless registers
        process_entry(registers, values, calculator)
      end
      result << build_substitute(calculator)
      result.flatten!
      result.compact!
      result
    end

    private

    def process_entry(registers, values, calculator)
      registers.collect do |register|
        calculator.process(values, register)
        if register.label.production? || register.label.consumption?
          build_bubble(register, values)
        end
      end
    end

    def build_bubble(register, values)
      Bubble.new(value: to_watt(values, register).to_i, register: register)
    end

    def build_substitute(calculator)
      substitute = registers.find {|r| r.is_a?(Register::Substitute)}
      if substitute
        value = calculator.value(substitute)
        Bubble.new(value: value, register: substitute)
      end
    end

  end
end
