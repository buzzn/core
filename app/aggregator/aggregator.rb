require 'benchmark'
class Aggregator

  attr_accessor :metering_point_ids, :energys

  def initialize(initialize_params = {})
    @metering_point_ids = initialize_params.fetch(:metering_point_ids, nil) || nil
    @example            = initialize_params.fetch(:example, ['slp']) || ['slp']
  end



  def power(params = {})
    @cache_id = "/aggregate/power?metering_point_ids=#{@metering_point_ids.join(',')}"
    if Rails.cache.exist?(@cache_id)
      @power = Rails.cache.fetch(@cache_id)
    else
      seconds_to_process = Benchmark.realtime do
        @power_items = []
        @timestamp = params.fetch(:timestamp, Time.current) || Time.current

        buzzn_api_metering_points, discovergy_metering_points, slp_metering_points = metering_points_sort(@metering_point_ids)

        ['in', 'out'].each do |mode|
          buzzn_api_metering_points[mode.to_sym].each do |metering_point|
            document = Reading.where(meter_id: metering_point.meter.id, :timestamp.gte => @timestamp).last

            item = {'timestamp' => document['timestamp']}
            item.merge!('power_milliwatt' => document['power_milliwatt']) if document['power_milliwatt']
            item.merge!('energy_a_milliwatt_hour' => document['energy_a_milliwatt_hour']) if document['energy_a_milliwatt_hour']
            item.merge!('energy_b_milliwatt_hour' => document['energy_b_milliwatt_hour']) if document['energy_b_milliwatt_hour']

            @power_items << {
              "operator" => (mode == 'in' ? '+' : '-'),
              "data" => item
            }
          end

          # discovergy
          discovergy_metering_points[mode.to_sym].each do |metering_point|
            @power_items << {
              "operator" => (mode == 'in' ? '+' : '-'),
              "data" => external_data(metering_point, @resolution, @timestamp.to_i*1000)
            }
          end
        end

        #slp
        if slp_metering_points.any?
          document = Reading.where(:timestamp.gte => (@timestamp - 15.minutes), :timestamp.lte => (@timestamp + 15.minutes), source: 'slp').last
          slp_metering_points.each do |metering_point|
            factor = factor_from_metering_point(metering_point)

            item = {'timestamp' => document['timestamp']}
            item.merge!('power_milliwatt' => document['power_milliwatt'] * factor) if document['power_milliwatt']
            item.merge!('energy_a_milliwatt_hour' => document['energy_a_milliwatt_hour'] * factor) if document['energy_a_milliwatt_hour']
            item.merge!('energy_b_milliwatt_hour' => document['energy_b_milliwatt_hour'] * factor) if document['energy_b_milliwatt_hour']

            @power_items <<  { "operator" => "+", "data" => item }
          end
        end

      end
    end

    @power = sum_power_items(@power_items)

    if seconds_to_process > 2
      Rails.cache.write(@cache_id, @power, expires_in: 5.seconds)
    end
    return @power
  end





  def energy(params = {})
    @cache_id = "/aggregate/energy?metering_point_ids=#{@metering_point_ids.join(',')}&timestamp=#{@timestamp}&resolution=#{@resolution}"

    if Rails.cache.exist?(@cache_id)
      @energy = Rails.cache.fetch(@cache_id)
    else
      seconds_to_process = Benchmark.realtime do
        @energy_items = []
        @timestamp  = params.fetch(:timestamp, Time.current) || Time.current
        @resolution = params.fetch(:resolution, 'day_to_hours') || 'day_to_hours'

        buzzn_api_metering_points, discovergy_metering_points, slp_metering_points = metering_points_sort(@metering_point_ids)

        ['in', 'out'].each do |mode|
          # buzzn_api
          if buzzn_api_metering_points[mode.to_sym].any?
            source = { meter_id: { "$#{mode}" => buzzn_api_metering_points[mode.to_sym].collect(&:meter_id) } }
            keys = [key_from_resolution_and_mode(@resolution, mode)]
            collection = Reading.aggregate(@resolution, source, @timestamp, keys)
            @energy_items << {
              "operator" => (mode == 'in' ? '+' : '-'),
              "data" => collection_to_hash(collection, 1)
            }
          end

          # discovergy
          discovergy_metering_points[mode.to_sym].each do |metering_point|
            @energy_items << {
              "operator" => (mode == 'in' ? '+' : '-'),
              "data" => external_data(metering_point, @resolution, @timestamp.to_i*1000)
            }
          end
        end

        #slp
        if slp_metering_points.any?
          source = { source: { "$in" => ['slp'] } }
          keys = [key_from_resolution_and_mode(@resolution, 'in')]
          collection = Reading.aggregate(@resolution, source, @timestamp, keys)
          slp_metering_points.each do |metering_point|
            factor = factor_from_metering_point(metering_point)
            @energy_items << { "operator" => "+", "data" => collection_to_hash(collection, factor) }
          end
        end
        @energy = sum_energy_items(@energy_items)

      end
      if seconds_to_process > 2
        Rails.cache.write(@cache_id, @energy, expires_in: 1.minute)
      end
    end
    return @energy
  end



private

  def factor_from_metering_point(metering_point)
     metering_point.forecast_kwh_pa ? (metering_point.forecast_kwh_pa/1000) : 1
  end

  def key_from_resolution_and_mode(resolution, mode)
    if Reading.energy_resolutions.include?(resolution)
      case mode
      when 'in'
        return 'energy_a_milliwatt_hour'
      when 'out'
        return 'energy_b_milliwatt_hour'
      else
        "You gave me mode: #{mode} -- I have no idea what to do with that."
      end
    elsif Reading.power_resolutions.include?(resolution)
      return 'power_milliwatt'
    end
  end

  def sum_power_items(power_items)
    if power_items.count > 1
      power_tamplate  = power_items.pop
      power           = power_tamplate['data']
      power_keys      = power_tamplate['data'].keys
      power_keys.delete('timestamp')
      power_items.each do |power_item|
        operator        = power_item['operator']
        power_item_data = power_item['data']

        power_keys.each do |key|
          case operator
          when '+'
            power[key] += power_item_data[key]
          when '-'
            power[key] -= power_item_data[key]
          else
            "You gave me operator: #{operator} -- I have no idea what to do with that."
          end
        end

      end
      return power
    else
      return power_items.first['data']
    end
  end

  def sum_energy_items(energy_items)
    if energy_items.count > 1
      energy_tamplate  = energy_items.pop
      energy           = energy_tamplate['data']
      energy_keys      = energy_tamplate['data'].first.keys
      energy_keys.delete('timestamp')
      energy_items.each do |energy_item|
        operator          = energy_item['operator']
        energy_item_data  = energy_item['data']
        energy_item_data.each_with_index do |item, index|
          energy_keys.each do |key|
            case operator
            when '+'
              energy[index][key] += item[key]
            when '-'
              energy[index][key] -= item[key]
            else
              "You gave me operator: #{operator} -- I have no idea what to do with that."
            end
          end
        end
      end
      return energy
    else
      return energy_items.first['data']
    end
  end



  def metering_points_sort(metering_point_ids)
    buzzn_api_metering_points   = { in:[], out:[] }
    discovergy_metering_points  = { in:[], out:[] }
    slp_metering_points         = []
    MeteringPoint.where(id: @metering_point_ids).each do |metering_point|
      case metering_point.data_source
      when 'buzzn-api'
        case metering_point.mode
        when 'in'
          buzzn_api_metering_points[:in] << metering_point
        when 'out'
          buzzn_api_metering_points[:out] << metering_point
        end
      when 'discovergy'
        case metering_point.mode
        when 'in'
          discovergy_metering_points[:in] << metering_point
        when 'out'
          discovergy_metering_points[:out] << metering_point
        end
      when 'slp'
        slp_metering_points << metering_point
      else
        Rails.logger.error "You gave me #{metering_point.data_source} -- I have no idea what to do with that."
      end
    end
    return buzzn_api_metering_points, discovergy_metering_points, slp_metering_points
  end


  def collection_to_hash(collection, factor=1)
    items = []
    collection.each do |document|
      item = {'timestamp' => document['firstTimestamp']}
      item.merge!('power_milliwatt' => document['avgPowerMilliwatt'] * factor) if document['avgPowerMilliwatt']
      item.merge!('energy_a_milliwatt_hour' => document['sumEnergyAMilliwattHour'] * factor) if document['sumEnergyAMilliwattHour']
      item.merge!('energy_b_milliwatt_hour' => document['sumEnergyBMilliwattHour'] * factor) if document['sumEnergyBMilliwattHour']
      items << item
    end
    return items
  end




  def external_data(metering_point, resolution, timestamp)
    items = []
    crawler = Crawler.new(metering_point)

    if resolution == 'hour_to_minutes'
      result = crawler.hour(timestamp)

    elsif resolution == 'day_to_minutes'
      result = crawler.day(timestamp)
      result.each do |item|
        items << {
          timestamp: Time.at(item[0]/1000),
          power_milliwatt: (item[1]*1000).to_i
        }
      end

    elsif resolution == 'month_to_days'
      result = crawler.month(timestamp)

    elsif resolution == 'year_to_months'
      result = crawler.year(timestamp)

    end
    return items
  end



end
