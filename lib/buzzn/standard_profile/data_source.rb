module Buzzn::StandardProfile
  class DataSource

    def initialize(facade = Facade.new)
      @facade = facade
    end

    def single_value(register, timestamp)
      value(['power'], register, timestamp)
    end

    def value_list
    end

    def chart(register, interval)
      case interval.duration
      when :day
        resolution  = :day_to_minutes
        units       = ['power']
      when :month
        resolution  = :month_to_days
        units       = ['energy']
      when :year
        resolution  = :year_to_months
        units       = ['energy']
      else
        raise Buzzn::DataSourceError.new('unknown interval duration')
      end
      range(
        units,
        register,
        interval.from_as_time, 
        interval.to_as_time,
        resolution
      )
    end


private

    # Register Ticker
    def value(units, register, timestamp)
      query_value_result = @facade.query_value(register.data_source, timestamp, units)
      to_data_result(register, query_value_result, units)
    end

    # Register Chart
    def range(units, register, from, to, resolution)
      query_range_result = @facade.query_range(register.data_source, from, to, resolution, units)
      to_data_result_set(register, query_range_result, units)
    end

    # Group Bubbles
    def value_collection()
    end

    # Group Ticker
    def value_aggregation()
    end

    # Group Chart
    def range_aggregation()
    end


    def to_data_result(register, query_value_result, units)
      timestamp   = query_value_result.timestamp.to_time
      value       = query_value_result.energy_milliwatt_hour if units.include?('energy')
      value       = query_value_result.power_milliwatt if units.include?('power')
      resource_id = register.id
      mode        = register.mode
      Buzzn::DataResult.new(timestamp, value, resource_id, mode)
    end

    def to_data_result_set(register, query_range_result, units)
      data_result_set = Buzzn::DataResultSet.milliwatt(register.id)
      factor = factor_from_register(register)
      query_range_result.each do |document|
        if units.include?('energy')
          timestamp = document['firstTimestamp']
          value     = document['sumEnergyMilliwattHour'] * factor
        end
        if units.include?('power')
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
