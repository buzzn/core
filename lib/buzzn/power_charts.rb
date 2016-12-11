module Buzzn

  class PowerCharts

    def initialize(data_source_registry)
      @registry = data_source_registry
    end

    def for_register(register, interval)
      check_interval(interval)
      mode = register.is_a?(Register::Input)? :in : :out
      result = @registry.get(register.data_source).aggregated(register, interval, mode)
      result.units(:milliwatt)
      result
    end

    def for_group(group, interval)
      check_interval(interval)
      result = Buzzn::DataResultSet.new(group.id)
      @registry.each do |key, data_source|
        result.add_all(data_source.aggregated(group, interval, :in))
        result.add_all(data_source.aggregated(group, interval, :out))
      end
      result.units(:milliwatt)
      result
    end

    private

    def check_interval(interval)
      if interval.month? || interval.year?
        raise Buzzn::DataSourceError.new('ERROR - you requested data with wrong resolution')
      end
    end
  end
end
