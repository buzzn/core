module Buzzn

  class Charts

    def initialize(data_source_registry)
      @registry = data_source_registry
    end

    def for_register(register, interval)
      mode = register.is_a?(Register::Input)? :in : :out
      @registry.get(register.data_source).aggregated(register, interval, mode)
    end

    def for_group(group, interval)
      units = interval.hour? || interval.day? ? :milliwatt : :milliwatt_hour
      result = Buzzn::DataResultSet.send(units, group.id)
      @registry.each do |key, data_source|
        result.add_all(data_source.aggregated(group, interval, :in))
        result.add_all(data_source.aggregated(group, interval, :out))
      end
      result.freeze
      result
    end

  end
end
