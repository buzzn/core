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
      log_network_loss(calculator)
      result << build_substitute(calculator)
      result << build_virtual(calculator)
      result.flatten!
      result.compact!
      result
    end

    private

    def process_entry(registers, values, calculator)
      registers.collect do |register|
        calculator.process(values, register)
        if register.production? || register.consumption?
          build_bubble(register, values)
        end
      end
    end

    def build_bubble(register, values)
      Bubble.new(value: to_watt(values, register).to_i, register: register)
    end

    def log_network_loss(calculator)
      if calculator.virtual_value.nil?
        logger.info { "network_loss/error #{calculator.substitute.round(2)} W" }
      end
    end

    def build_substitute(calculator)
      substitute = registers.find {|r| r.is_a?(Register::Substitute)}
      if substitute
        value = calculator.value(substitute)
        Bubble.new(value: value, register: substitute)
      end
    end

    def build_virtual(calculator)
      if value = calculator.virtual_value
        calculator.missing_registers.collect do |register|
          Bubble.new(value: value, register: register)
        end
      end
    end

  end
end
