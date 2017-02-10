module Buzzn

  class Charts

    def initialize(data_source_registry)
      @registry = data_source_registry
    end

    def for_register(register, interval)
      raise ArgumentError.new("not a #{Register::Base}") unless register.is_a?(Register::Base)
      raise ArgumentError.new("not a #{Buzzn::Interval}") unless interval.is_a?(Buzzn::Interval)
      @registry.get(register.data_source).aggregated(register, register.direction, interval)
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
