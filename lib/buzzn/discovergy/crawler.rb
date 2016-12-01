require 'buzzn'

module Buzzn::Discovergy

  # the discovergy crawler uses the API from discovergy to retrieve
  # readings and produces a CrawlerResult object
  class Crawler

    def initialize(url, max_concurrent)
      @facade = Facade.new(url, max_concurrent)
    end

    def collection(broker, interval, mode)
      # TODO: check that broker is only for a group or virtual meter!
      response = @facade.readings(broker, interval, mode, true)
      result = parse_collected_data(response, interval)
      result.freeze
      result
    end

    def aggregated(broker, interval, mode)
      # NOTE: broker may be for a group, a virtual meter OR a real meter!
      two_way_meter = broker.resource.is_a?(Meter) && broker.resource.registers.size > 1
      external_id = broker.external_id
      response = @facade.readings(broker, interval, mode, false)
      result = parse_aggregated_data(response, interval, mode, two_way_meter, external_id)
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
        raise Buzzn::CrawlerError.new('Group has to contain more than one meter.')
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
      json = MultiJson.load(response.body)

      if interval.live?
        result << parse_aggregated_live(json, mode, two_way_meter, external_id)
      elsif interval.hour?
        result << parse_aggregated_hour(json, mode, two_way_meter, external_id)
      elsif interval.day?
        result << parse_aggregated_day(json, mode, two_way_meter, external_id)
      elsif interval.month? || interval.year?
        result << parse_aggregated_month_year(json, mode, two_way_meter, external_id)
      end
      return result
    end

    def parse_aggregated_live(json, mode, two_way_meter, external_id)
      result = Buzzn::CrawlerResult.new(external_id)
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
      result = Buzzn::CrawlerResult.new(external_id)
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
      result = Buzzn::CrawlerResult.new(external_id)
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
      result = Buzzn::CrawlerResult.new(external_id)
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
      json = MultiJson.load(response.body)
      if interval.live?
        json.each do |item|
          external_id = item.first
          timestamp = item[1]['time']
          value = item[1]['values']['power']
          result_item = Buzzn::CrawlerResult.new(external_id)
          result_item.add(timestamp, value)
          result << result_item
        end
      elsif interval.hour?
        # should not be possible
      elsif interval.day?
        # should not be possible
      elsif interval.month?
        # should not be possible
      elsif interval.year?
        # should not be possible
      end
      return result
    end
  end
end
