module Buzzn::Discovergy

  # the discovergy dataSource uses the API from discovergy to retrieve
  # readings and produces a DataResult object
  class DataSource < Buzzn::DataSource

    def initialize(facade = Facade.new, cache_time = 15)
      @facade = facade
      @cache_time = cache_time
    end

    ##########################
    # internal data-source api
    ##########################

    def collection(group_or_virtual_register, mode)
      if group_or_virtual_register.discovergy_brokers.empty?
        result = Buzzn::DataResultArray.new(expires_at)
        group_or_virtual_register.registers.each do |register|
          result << single_aggregated(register, mode)
        end
        result.compact!
        return result
      end

      map = to_map(group_or_virtual_register)
      result = Buzzn::DataResultArray.new(expires_at)
      group_or_virtual_register.discovergy_brokers.each do |broker|
        response = @facade.readings(broker, nil, mode, true)

        result += parse_collected_data(response, mode, map)
      end
      result.freeze if result
      result
    end

    def single_aggregated(register_or_group, mode)
      result = nil
      register_or_group.discovergy_brokers.each do |broker|
        two_way_meter = broker.two_way_meter?

        response = @facade.readings(broker, nil, mode, false)
        
        result = add(result, parse_aggregated_live(response, mode, two_way_meter, register_or_group.id))
      end
      result.freeze if result
      result
    end

    def aggregated(register_or_group, mode, interval)
      result = nil
      register_or_group.discovergy_brokers.each do |broker|
        two_way_meter = broker.two_way_meter?
        response = @facade.readings(broker, interval, mode, false)

        result = add(result, parse_aggregated_data(response, interval, mode, two_way_meter, register_or_group.id))
      end
      result.freeze if result
      result
    end


    ######################################
    # discovergy specifics for data-source
    ######################################

    def add(result, more)
      if result
        result.add_all(more)
      else
        result = more
      end
      result
    end

    def create_virtual_meter_for_register(register)
      if !register.is_a?(Register) || !register.virtual
        raise Buzzn::DataSourceError.new('ERROR - no virtual meters for non-virtual registers')
      end
      meter = register.meter
      # TODO: make this SQL faster
      meter_ids_plus = register.formula_parts.additive.collect(&:operand).collect(&:meter).uniq.compact.collect(&:manufacturer_product_serialnumber).map{|s| 'EASYMETER_' + s}
      meter_ids_minus = register.formula_parts.subtractive.collect(&:operand).collect(&:meter).uniq.compact.collect(&:manufacturer_product_serialnumber).map{|s| 'EASYMETER_' + s}
      if meter_ids_plus.size + meter_ids_minus.size < 2
        raise Buzzn::DataSourceError.new('Formula has to contain more than one meter.')
      end
      #TODO: write credentials into secrets or elsewhere ...
      existing_random_broker = DiscovergyBroker.where(provider_login: 'team@localpool.de').first
      response = @facade.create_virtual_meter(existing_random_broker, meter_ids_plus, meter_ids_minus, false)
      broker = parse_virtual_meter_creation(response.body, 'virtual', meter)
      return broker
    end

    def create_virtual_meters_for_group(group)
      # TODO: make this SQL faster
      in_meter_ids = group.registers.inputs.collect(&:meter).uniq.compact.collect(&:manufacturer_product_serialnumber).map{|s| 'EASYMETER_' + s}
      out_meter_ids = group.registers.outputs.collect(&:meter).uniq.compact.collect(&:manufacturer_product_serialnumber).map{|s| 'EASYMETER_' + s}
      existing_random_broker = DiscovergyBroker.where(provider_login: 'team@localpool.de').first
      if in_meter_ids.size > 1
        response = @facade.do_create_virtual_meter(existing_random_broker, in_meter_ids)
        in_broker = parse_virtual_meter_creation(response.body, 'in', group)
      end
      if out_meter_ids.size > 1
        response = @facade.do_create_virtual_meter(existing_random_broker, out_meter_ids)
        out_broker = parse_virtual_meter_creation(response.body, 'out', group)
      end
      return [in_broker, out_broker].compact
    end

    private

    def expires_at
      Time.current.to_i + @cache_time
    end

    def to_map(resource)
      case resource
      when Group
        to_group_map(resource)
      when Register::Base
        to_register_map(resource)
      end
    end

    def to_group_map(group)
      meter_to_register = {}
      group.registers.each do |r|
        meter_to_register[r.meter_id] = r.id
      end
      to_external_map(meter_to_register)
    end

    def to_register_map(register)
      meter_to_register = {}
      register.formula_parts.each do |r|
        meter_to_register[r.operand.meter_id] = r.operand.id
      end
      to_external_map(meter_to_register)
    end

    def to_external_map(meter_to_register)
      map = {}
      DiscovergyBroker.where(resource_id:  meter_to_register.keys).select(:external_id, :resource_id).each do |broker|
        map[broker.external_id] = meter_to_register[broker.resource_id]
      end
      map
    end

    ##############
    ### PARSER ###
    ##############

    def parse_aggregated_data(response, interval, mode, two_way_meter, resource_id)
      json = MultiJson.load(response)
      if json.empty?
        return nil
      end

      case interval.duration
      when :hour
        parse_aggregated_hour(json, mode, two_way_meter, resource_id)
      when :day
        parse_aggregated_day(json, mode, two_way_meter, resource_id)
      else
        parse_aggregated_month_year(json, mode, two_way_meter, resource_id)
      end
    end

    def parse_aggregated_live(response, mode, two_way_meter, resource_id)
      json = MultiJson.load(response)
      if json.empty?
        return nil
      end

      timestamp = json['time']
      value = json['values']['power']
      if two_way_meter
        if value > 0 && mode == :in
          power = value/1000
        elsif value < 0 && mode == :out
          power = value.abs/1000
        else
          power = 0
        end
      else
        power = value > 0 ? value.abs/1000 : 0
      end
      Buzzn::DataResult.new(Time.at(timestamp/1000.0), power, resource_id, mode, expires_at)
    end

    def parse_aggregated_hour(json, mode, two_way_meter, resource_id)
      result = Buzzn::DataResultSet.milliwatt(resource_id)
      json.each do |item|
        if two_way_meter
          if item['values']['power'] > 0 && mode == :in
            power = item['power']
          elsif item['values']['power'] < 0 && mode == :out
            power = item['values']['power'].abs
          else
            power = 0
          end
        else
          power = item['values']['power'] > 0 ? item['values']['power'].abs : 0
        end
        timestamp = item['time']
        result.add(Time.at(timestamp/1000.0), power, mode)
      end
      return result
    end

    def parse_aggregated_day(json, mode, two_way_meter, resource_id)
      result = Buzzn::DataResultSet.milliwatt(resource_id)
      energy_out = mode == :in ? "" : "Out"
      first_reading = first_timestamp = nil
      json.each do |item|
        second_timestamp = item['time']
        second_reading = item['values']["energy#{energy_out}"]
        if first_timestamp
          power = (second_reading - first_reading)/(2500.0) # convert vsm to power (mW)
          result.add(Time.at(first_timestamp/1000.0), power, mode)
        end
        first_timestamp = second_timestamp
        first_reading = second_reading
      end
      return result
    end

    def parse_aggregated_month_year(json, mode, two_way_meter, resource_id)
      result = Buzzn::DataResultSet.milliwatt_hour(resource_id)
      energy_out = mode == :in ? "" : "Out"
      old_value = new_value = timestamp = i = 0
      if two_way_meter && mode == :out
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
        result.add(Time.at(timestamp/1000.0), (new_value - old_value)/10000.0, mode) #convert to mWh
        old_value = new_value
        timestamp = item['time']
        i += 1
      end
      return result
    end

    def parse_collected_data(response, mode, map)
      result = Buzzn::DataResultArray.new(expires_at)
      json = MultiJson.load(response)
      json.each do |item|
        resource_id = map[item.first]
        timestamp = item[1]['time']
        value = item[1]['values']['power']
        result_item = Buzzn::DataResult.new(Time.at(timestamp/1000.0), value, resource_id, mode, expires_at)
        result << result_item
      end
      return result
    end

    def parse_virtual_meter_creation(response, mode, resource)
      json = MultiJson.load(response)
      # TODO: Move credentials into secrets
      broker = DiscovergyBroker.create!(
        mode: mode,
        external_id: json['type'] + '_' + json['serialNumber'],
        provider_login: 'team@localpool.de',
        provider_password: 'Zebulon_4711',
        resource: resource
      )
      return broker
    end

    # need it at end to see all the methods
    include Buzzn::DataSourceCaching
  end
end
