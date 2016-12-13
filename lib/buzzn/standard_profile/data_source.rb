module Buzzn::StandardProfile
  class DataSource

    def initialize(facade = Facade.new)
      @facade = facade
    end



    # Register Power Ticker
    def power_value(profile, interval)
      @facade.query_value(profile, interval)
    end

    # Register Energy Ticker
    def energy_value(profile)
      @facade.query_value(profile, interval)
    end

    # Register Power Line Chart
    def power_range(profile)
      @facade.query_range(profile, interval, ['power'])
    end

    # Register Energy Bar Chart
    def energy_range(profile)
      @facade.query_range(profile, interval, ['energy'])
    end

    # Group Bubbles
    def power_value_collection(profile)
    end

    # Group Power Ticker
    def power_value_aggregation(profile, interval)
    end

    # Group Power Chart
    def power_range_aggregation(profile)
    end

    # Group Energy Chart
    def energy_range_aggregation(profile)
    end




private

    def range_to_data(response, factor=1)
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


  end
end
