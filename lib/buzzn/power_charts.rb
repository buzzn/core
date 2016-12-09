module Buzzn

  class PowerCharts

    def initialize(data_source_registry)
      @registry = data_source_registry
    end

    def for_register(register, interval)
      check_not_live(interval)
      mode = register.is_a?(Register::Input)? :in : :out
      @registry.get(register.data_source).aggregated(register, interval, mode)
    end

    def for_group(group, interval)
      check_not_live(interval)
      result = Buzzn::DataResultSet.new(group.id)
      @registry.each do |key, data_source|
        result.add_all(data_source.aggregated(group, interval, :in))
        result.add_all(data_source.aggregated(group, interval, :out))
      end
      result
    end

    private

    def check_not_live(interval)
      if interval.live?
        raise Buzzn::DataSourceError.new('ERROR - you requested collected data with wrong resolution')
      end
    end
  end
end
