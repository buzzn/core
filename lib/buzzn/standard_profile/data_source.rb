module Buzzn::StandardProfile
  class DataSource

    def initialize(facade = Facade.new)
      @facade = facade
    end



    # Register Power Ticker
    def power_value(register, timestamp)
      keys = ['power']
      value = @facade.query_value(register.data_source, timestamp, keys)
      value_to_data_result(register, value, keys)
    end

    # Register Energy Ticker
    def energy_value(register, timestamp)
      keys = ['energy']
      value = @facade.query_value(register.data_source, timestamp, keys)
      value_to_data_result(register, value, keys)
    end

    # Register Power Line Chart
    def power_range(register, from, to, resolution )
      keys = ['power']
      range = @facade.query_range(register.data_source, from, to, keys)
      range_to_data_result_set(register, range, keys)
    end

    # # Register Energy Bar Chart
    # def energy_range(profile)
    #   @facade.query_range(profile, interval, ['energy'])
    # end

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

    def value_to_data_result(register, value, keys)
      data_result = Buzzn::DataResult.new(register.id)
      data_result.add(value.timestamp, value.energy_milliwatt_hour) if keys.include?('energy')
      data_result.add(value.timestamp, value.power_milliwatt) if keys.include?('power')
      data_result
    end

    def range_to_data_result_set(response)
      items = []
      response.each do |document|

        item = {
          'from' => document['firstTimestamp'],
          'to'  => document['lastTimestamp']
        }

        if document['sumEnergyMilliwattHour']
          energy_milliwatt_hour = document['sumEnergyMilliwattHour'] * factor
          item.merge!('energy_milliwatt_hour' => energy_milliwatt_hour)
        end

        if document['avgPowerMilliwatt']
          power_milliwatt = document['avgPowerMilliwatt'] * factor
          item.merge!('power_milliwatt' => power_milliwatt.to_i)
        end

        items << item
      end
      return items
    end

    def factor_from_register(register)
       register.forecast_kwh_pa ? (register.forecast_kwh_pa/1000.0) : 1
    end

  end
end
