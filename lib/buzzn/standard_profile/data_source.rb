module Buzzn::StandardProfile
  class DataSource

    def initialize(facade = Facade.new)
      @facade = facade
    end



    # Register Power Ticker
    def power_value(register, timestamp)
      keys = ['power']
      query_value_result = @facade.query_value(register.data_source, timestamp, keys)
      to_data_result(register, query_value_result, keys)
    end

    # Register Energy Ticker
    def energy_value(register, timestamp)
      keys = ['energy']
      query_value_result = @facade.query_value(register.data_source, timestamp, keys)
      to_data_result(register, query_value_result, keys)
    end

    # Register Power Line Chart
    def power_range(register, from, to, resolution)
      keys = ['power']
      query_range_result = @facade.query_range(register.data_source, from, to, resolution, keys)
      to_data_result_set(register, query_range_result, keys)
    end

    # Register Energy Bar Chart
    def energy_range(register, from, to, resolution)
      keys = ['energy']
      query_range_result = @facade.query_range(register.data_source, from, to, resolution, keys)
      to_data_result_set(register, query_range_result, keys)
    end

    # # Group Bubbles
    # def power_value_collection(profile)
    # end

    # # Group Power Ticker
    # def power_value_aggregation(profile, interval)
    # end

    # # Group Power Chart
    # def power_range_aggregation(profile)
    # end

    # # Group Energy Chart
    # def energy_range_aggregation(profile)
    # end




private

    def to_data_result(register, query_value_result, keys)
      timestamp   = query_value_result.timestamp.to_time
      value       = query_value_result.energy_milliwatt_hour if keys.include?('energy')
      value       = query_value_result.power_milliwatt if keys.include?('power')
      resource_id = register.id
      mode        = register.mode
      Buzzn::DataResult.new(timestamp, value, resource_id, mode)
    end

    def to_data_result_set(register, query_range_result, keys)
      data_result_set = Buzzn::DataResultSet.milliwatt(register.id)
      factor = factor_from_register(register)
      query_range_result.each do |document|
        if keys.include?('energy')
          timestamp = document['firstTimestamp']
          value     = document['sumEnergyMilliwattHour'] * factor
        end
        if keys.include?('power')
          timestamp = document['firstTimestamp']
          value     = document['avgPowerMilliwatt'] * factor
        end
        data_result_set.add(timestamp, value, register.mode.to_sym)
      end
      data_result_set
    end

    def factor_from_register(register)
       register.forecast_kwh_pa ? (register.forecast_kwh_pa/1000.0) : 1
    end

  end
end
