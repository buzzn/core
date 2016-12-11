module Buzzn

  class EnergyCharts

    def initialize(data_source_registry)
      @registry = data_source_registry
    end

    def for_register(register, interval)
      check_interval(interval)
      mode = register.is_a?(Register::Input)? :in : :out

      result = Buzzn::DataResultSet.new(group.id)

      #TODO

      result.units(:milliwatt_hour)
      result
    end

    def for_group(group, interval)
      check_interval(interval)
      result = Buzzn::DataResultSet.new(group.id)

      # TODO

      result.units(:milliwatt_hour)
      result
    end

    private

    def check_interval(interval)
      if interval.hour? || interval.day?
        raise Buzzn::DataSourceError.new('ERROR - you requested data with wrong resolution')
      end
    end
  end
end
