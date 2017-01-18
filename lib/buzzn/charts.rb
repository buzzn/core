module Buzzn

  class Charts

    def initialize(data_source_registry)
      @registry = data_source_registry
    end

    def for_register(register, interval)
      raise ArgumentError.new("not a #{Register::Base}") unless register.is_a?(Register::Base)
      raise ArgumentError.new("not a #{Buzzn::Interval}") unless interval.is_a?(Buzzn::Interval)
      if register.is_a?(Register::Virtual)
        units = interval.hour? || interval.day? ? :milliwatt : :milliwatt_hour
        result = Buzzn::DataResultSet.send(units, register.id)
        register.formula_parts.each do |formula_part|
          mode = formula_part.operand.direction
          data = @registry.get(formula_part.operand.data_source).aggregated(formula_part.operand, mode, interval)
          formula_part.operator == '+' ? result.add_all(data, interval.duration) : result.subtract_all(data, interval.duration)
        end
        result.combine(register.direction, interval.duration)
        return result
      else
        mode = register.direction
        @registry.get(register.data_source).aggregated(register, mode, interval)
      end
    end

    def for_group(group, interval)
      raise ArgumentError.new("not a #{Group}") unless group.is_a?(Group)
      raise ArgumentError.new("not a #{Buzzn::Interval}") unless interval.is_a?(Buzzn::Interval)
      units = interval.hour? || interval.day? ? :milliwatt : :milliwatt_hour
      result = Buzzn::DataResultSet.send(units, group.id)
      @registry.each do |key, data_source|
        result.add_all(data_source.aggregated(group, :in, interval), interval.duration)
        result.add_all(data_source.aggregated(group, :out, interval), interval.duration)
      end
      result.freeze
      result
    end

  end
end
