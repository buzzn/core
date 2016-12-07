module Buzzn::Discovergy

  # the discovergy dataSource uses the API from discovergy to retrieve
  # readings and produces a DataResult object
  class DataSource

    def initialize(url='https://api.discovergy.com', max_concurrent=30)
      @facade = Facade.new(url, max_concurrent)
    end

    def collection(group, interval, mode)
      # TODO: check that broker is only for a group or virtual meter!
      if !interval.live?
        raise Buzzn::DataSourceError.new('ERROR - you requested collected data with wrong period')
      end
      response = @facade.readings(group.discovergy_broker, interval, mode, true)
      result = parse_collected_data(response.body, interval)
      result.freeze
      result
    end

    def aggregated(meter_or_group, interval, mode)
      # NOTE: broker may be for a group, a virtual meter OR a real meter!
      two_way_meter = broker.two_way_meter?
      external_id = broker.external_id
      response = @facade.readings(meter_or_group.discovergy_broker, interval, mode, false)
      result = parse_aggregated_data(response.body, interval, mode, two_way_meter, external_id)
      result.freeze
      result
    end

    def create_virtual_meter_for_register(register)
      result = []
      # TODO: get all the serialnumbers of all input and output registers
      meter_ids_plus = register.formula_parts.additive.collect(&:operand).collect(&:meter).uniq.compact.collect(&:manufacturer_product_serialnumber).map{|s| 'EASYMETER_' + s}
      meter_ids_minus = register.formula_parts.subtractive.collect(&:operand).collect(&:meter).uniq.compact.collect(&:manufacturer_product_serialnumber).map{|s| 'EASYMETER_' + s}
      #TODO: write credentials into secrets or elsewhere ...
      existing_random_broker = DiscovergyBroker.where(provider_login: 'team@localpool.de').first
      response = @facade.create_virtual_meter(existing_random_broker, meter_ids_plus, meter_ids_minus, false)
      #TODO parse response
      result.freeze
      result

    end

    def create_virtual_meters_for_group(group)
      result = []
      in_meter_ids = group.registers.inputs.collect(&:meter).uniq.compact.collect(&:manufacturer_product_serialnumber).map{|s| 'EASYMETER_' + s}
      out_meter_ids = group.registers.outputs.collect(&:meter).uniq.compact.collect(&:manufacturer_product_serialnumber).map{|s| 'EASYMETER_' + s}
      if in_meter_ids.size < 2 || out_meter_ids.size < 2
        raise Buzzn::DataSourceError.new('Group has to contain more than one meter.')
      end
      #TODO: write credentials into secrets or elsewhere ...
      existing_random_broker = DiscovergyBroker.where(provider_login: 'team@localpool.de').where(provider_password: 'Zebulon_4711').first
      response = @facade.create_virtual_meter(existing_random_broker, in_meter_ids)
      #TODO parse response
      response = @facade.create_virtual_meter(existing_random_broker, out_meter_ids)
      #TODO parse response
      result.freeze
      result

      # TODO: send request
      # TODO: store Broker

    end


    ##############
    ### PARSER ###
    ##############

    def parse_aggregated_data(response, interval, mode, two_way_meter, external_id)
      result = []
      json = MultiJson.load(response)

      case interval.period
      when :live
        result << parse_aggregated_live(json, mode, two_way_meter, external_id)
      when :hour
        result << parse_aggregated_hour(json, mode, two_way_meter, external_id)
      when :day
        result << parse_aggregated_day(json, mode, two_way_meter, external_id)
      else
        result << parse_aggregated_month_year(json, mode, two_way_meter, external_id)
      end
      return result
    end

    def parse_aggregated_live(json, mode, two_way_meter, external_id)
      result = Buzzn::DataResult.new(external_id)
      timestamp = json['time']
      value = json['values']['power']
      if two_way_meter
        if value > 0 && mode == 'in'
          power = value/1000
        elsif value < 0 && mode == 'out'
          power = value.abs/1000
        else
          power = 0
        end
      else
        power = value > 0 ? value.abs/1000 : 0
      end
      result.add(timestamp, power)
      return result
    end

    def parse_aggregated_hour(json, mode, two_way_meter, external_id)
      result = Buzzn::DataResult.new(external_id)
      json.each do |item|
        if two_way_meter
          if item['values']['power'] > 0 && mode == 'in'
            power = item['power']
          elsif item['values']['power'] < 0 && mode == 'out'
            power = item['values']['power'].abs
          else
            power = 0
          end
        else
          power = item['values']['power'] > 0 ? item['values']['power'].abs : 0
        end
        timestamp = item['time']
        result.add(timestamp, power)
      end
      return result
    end

    def parse_aggregated_day(json, mode, two_way_meter, external_id)
      result = Buzzn::DataResult.new(external_id)
      energy_out = mode == 'in' ? "" : "Out"
      first_reading = first_timestamp = nil
      json.each do |item|
        second_timestamp = item['time']
        second_reading = item['values']["energy#{energy_out}"]
        if first_timestamp
          power = (second_reading - first_reading)/(2500.0) # convert vsm to power (mW)
          result.add(first_timestamp, power)
        end
        first_timestamp = second_timestamp
        first_reading = second_reading
      end
      return result
    end

    def parse_aggregated_month_year(json, mode, two_way_meter, external_id)
      result = Buzzn::DataResult.new(external_id)
      energy_out = mode == 'in' ? "" : "Out"
      old_value = new_value = timestamp = i = 0
      if two_way_meter && mode == 'out'
        energy_out = 'Out'
      end
      json.each do |item|
        if i == 0
          old_value = item['values']["energy#{energy_out}"]
          timestamp = item['time']
          i += 1
          next
        end
        new_value = item['values']["energy#{energy_out}"]
        result.add(timestamp, (new_value - old_value)/10000.0) #convert to mWh
        old_value = new_value
        timestamp = item['time']
        i += 1
      end
      return result
    end

    def parse_collected_data(response, interval)
      result = []
      json = MultiJson.load(response)
      case interval.period
      when :live
        json.each do |item|
          external_id = item.first
          timestamp = item[1]['time']
          value = item[1]['values']['power']
          result_item = Buzzn::DataResult.new(external_id)
          result_item.add(timestamp, value)
          result << result_item
        end
      else
        raise Buzzn::DataSourceError.new('ERROR - you requested collected data with wrong period')
      end
      return result
    end
  end
end
