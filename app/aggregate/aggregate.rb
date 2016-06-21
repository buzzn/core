require 'benchmark'
class Aggregate

  attr_accessor :metering_point_ids, :energys

  def initialize(initialize_params = {})
    @metering_point_ids = initialize_params.fetch(:metering_point_ids, nil) || nil
  end



  def present(params = {})
    @cache_id = "/aggregate/present?metering_point_ids=#{@metering_point_ids.join(',')}"
    if Rails.cache.exist?(@cache_id)
      @present = Rails.cache.fetch(@cache_id)
    else
      seconds_to_process = Benchmark.realtime do
        @present_items = []
        @timestamp = params.fetch(:timestamp, Time.current) || Time.current

        buzzn_api_metering_points, discovergy_metering_points, slp_metering_points, sep_bhkw_metering_points, sep_pv_metering_points = metering_points_sort(@metering_point_ids)

        buzzn_api_metering_points.each do |metering_point|
          document = Reading.where(meter_id: metering_point.meter.id).order(timestamp: 'desc').first
          if document
            @present_items << {
              "operator" => (metering_point.mode == 'in' ? '+' : '-'),
              "data" => document_to_hash(document)
            }
          end
        end

        # discovergy
        discovergy_metering_points.each do |metering_point|
          @present_items << {
            "operator" => (metering_point.mode == 'in' ? '+' : '-'),
            "data" => external_data(metering_point, @resolution, @timestamp.to_i*1000)
          }
        end

        #slp
        if slp_metering_points.any?
          document = Reading.where(:timestamp.gte => @timestamp, source: 'slp').first
          slp_metering_points.each do |metering_point|
            factor = factor_from_metering_point(metering_point)
            @present_items << {
              "operator" => "+",
              "data" => document_to_hash(document, factor)
            }
          end
        end

        #sep_bhkw
        if sep_bhkw_metering_points.any?
          document = Reading.where(:timestamp.gte => @timestamp, source: 'sep_bhkw').first
          sep_bhkw_metering_points.each do |metering_point|
            factor = factor_from_metering_point(metering_point)
            @present_items << {
              "operator" => "+",
              "data" => document_to_hash(document, factor)
            }
          end
        end

        #sep_pv
        if sep_pv_metering_points.any?
          document = Reading.where(:timestamp.gte => @timestamp, source: 'sep_pv').first
          sep_pv_metering_points.each do |metering_point|
            factor = factor_from_metering_point(metering_point)
            @present_items << {
              "operator" => "+",
              "data" => document_to_hash(document, factor)
            }
          end
        end

      end
    end

    power_milliwatt_summed = 0
    @present_items.each do |present_item|
      case present_item['operator']
      when '+'
        power_milliwatt_summed += present_item['data']['power_a_milliwatt']
      when '-'
        power_milliwatt_summed -= present_item['data']['power_a_milliwatt']
      else
        "You gave me operator: #{operator} -- I have no idea what to do with that."
      end
    end

    @present = {
      "readings" => @present_items,
      "power_milliwatt_summed" => power_milliwatt_summed
    }

    if seconds_to_process > 2
      Rails.cache.write(@cache_id, @present, expires_in: 5.seconds)
    end
    return @present
  end





  def past(params = {})
    @cache_id = "/aggregate/past?metering_point_ids=#{@metering_point_ids.join(',')}&timestamp=#{@timestamp}&resolution=#{@resolution}"

    if Rails.cache.exist?(@cache_id)
      @past = Rails.cache.fetch(@cache_id)
    else
      seconds_to_process = Benchmark.realtime do
        @past_items = []
        @timestamp  = params.fetch(:timestamp, Time.current) || Time.current
        @resolution = params.fetch(:resolution, 'day_to_minutes') || 'day_to_minutes'

        buzzn_api_metering_points, discovergy_metering_points, slp_metering_points, sep_bhkw_metering_points, sep_pv_metering_points = metering_points_sort(@metering_point_ids)

        # buzzn_api
        buzzn_api_metering_points.each do |metering_point|
          source = { meter_id: { "$in" => [metering_point.meter.id] } }
          keys = [required_reading_attributes(@resolution, metering_point)]
          collection = Reading.aggregate(@resolution, source, @timestamp, keys)
          @past_items << aggregation_to_hash(collection, 1, metering_point.mode == 'in' ? false : true)
        end

        # discovergy
        discovergy_metering_points.each do |metering_point|
          @past_items << external_data(metering_point, @resolution, @timestamp.to_i*1000)
        end

        #slp
        if slp_metering_points.any?
          source = { source: { "$in" => ['slp'] } }
          if Reading.energy_resolutions.include?(@resolution)
            keys = ['energy_a_milliwatt_hour']
          elsif Reading.power_resolutions.include?(@resolution)
            keys = ['power_a_milliwatt']
          end
          collection = Reading.aggregate(@resolution, source, @timestamp, keys)
          slp_metering_points.each do |metering_point|
            factor = factor_from_metering_point(metering_point)
            @past_items << aggregation_to_hash(collection, factor, false)
          end
        end

        #sep_bhkw
        if sep_bhkw_metering_points.any?
          source = { source: { "$in" => ['sep_bhkw'] } }
          if Reading.energy_resolutions.include?(@resolution)
            keys = ['energy_a_milliwatt_hour']
          elsif Reading.power_resolutions.include?(@resolution)
            keys = ['power_a_milliwatt']
          end
          collection = Reading.aggregate(@resolution, source, @timestamp, keys)
          sep_bhkw_metering_points.each do |metering_point|
            factor = factor_from_metering_point(metering_point)
            @past_items << aggregation_to_hash(collection, factor, false)
          end
        end

        #sep_pv
        if sep_pv_metering_points.any?
          source = { source: { "$in" => ['sep_pv'] } }
          if Reading.energy_resolutions.include?(@resolution)
            keys = ['energy_a_milliwatt_hour']
          elsif Reading.power_resolutions.include?(@resolution)
            keys = ['power_a_milliwatt']
          end
          collection = Reading.aggregate(@resolution, source, @timestamp, keys)
          sep_pv_metering_points.each do |metering_point|
            factor = factor_from_metering_point(metering_point)
            @past_items << aggregation_to_hash(collection, factor, false)
          end
        end

        @past = sum_lists(@past_items)

      end
      if seconds_to_process > 2
        Rails.cache.write(@cache_id, @past, expires_in: 1.minute)
      end
    end
    return @past
  end



private

  def factor_from_metering_point(metering_point)
     metering_point.forecast_kwh_pa ? (metering_point.forecast_kwh_pa/1000) : 1
  end

  def required_register(metering_point)
    directions  = metering_point.meter.metering_points.count
    if directions == 1 && metering_point.input?
      register = 'a'
    elsif directions == 1 && metering_point.output?
      register = 'a'
    elsif directions == 2 && metering_point.input?
      register = 'a'
    elsif directions == 2 && metering_point.output?
      register = 'b'
    end
    return register
  end

  def required_reading_attributes(resolution, metering_point)
    register = required_register(metering_point)
    if Reading.energy_resolutions.include?(resolution)
      return "energy_#{register}_milliwatt_hour"
    elsif Reading.power_resolutions.include?(resolution)
      return "power_#{register}_milliwatt"
    end
  end



  def sum_lists(lists)
    if lists.count > 1
      tamplate_list  = lists.pop
      keys           = tamplate_list.first.keys
      keys.delete('timestamp')
      lists.each do |list|
        list.each_with_index do |item, index|
          keys.each do |key|
            tamplate_list[index][key] += item[key]
          end
        end
      end
      return tamplate_list

    else
      return lists.first

    end
  end



  def metering_points_sort(metering_point_ids)
    buzzn_api_metering_points   = []
    discovergy_metering_points  = []
    slp_metering_points         = []
    sep_bhkw_metering_points    = []
    sep_pv_metering_points      = []

    MeteringPoint.where(id: @metering_point_ids).each do |metering_point|
      case metering_point.data_source
      when 'buzzn-api'
        buzzn_api_metering_points << metering_point
      when 'discovergy'
        discovergy_metering_points << metering_point
      when 'slp'
        slp_metering_points << metering_point
      when 'sep_bhkw'
        sep_bhkw_metering_points << metering_point
      when 'sep_pv'
        sep_pv_metering_points << metering_point
      else
        Rails.logger.error "You gave me #{metering_point.data_source} -- I have no idea what to do with that."
      end
    end
    return buzzn_api_metering_points, discovergy_metering_points, slp_metering_points, sep_bhkw_metering_points, sep_pv_metering_points
  end


  def aggregation_to_hash(collection, factor=1, negativ=false)
    items = []

    # TODO DRY this
    collection.each do |document|
      item = {'timestamp' => document['firstTimestamp']}

      if document['sumEnergyAMilliwattHour']
        energy_a_milliwatt_hour = document['sumEnergyAMilliwattHour'] * factor
        energy_a_milliwatt_hour *= -1 if negativ
        item.merge!('energy_a_milliwatt_hour' => energy_a_milliwatt_hour)
      end

      if document['sumEnergyBMilliwattHour']
        energy_b_milliwatt_hour = document['sumEnergyBMilliwattHour'] * factor
        energy_b_milliwatt_hour *= -1 if negativ
        item.merge!('energy_b_milliwatt_hour' => energy_b_milliwatt_hour)
      end

      if document['avgPowerAMilliwatt']
        power_a_milliwatt = document['avgPowerAMilliwatt'] * factor
        power_a_milliwatt *= -1 if negativ
        item.merge!('power_a_milliwatt' => power_a_milliwatt)
      end

      if document['avgPowerBMilliwatt']
        power_b_milliwatt = document['avgPowerBMilliwatt'] * factor
        power_b_milliwatt *= -1 if negativ
        item.merge!('power_b_milliwatt' => power_b_milliwatt)
      end

      items << item
    end
    return items
  end


  def document_to_hash(document, factor=1, negativ=false)
    item = {'timestamp' => document['timestamp']}
    ['energy_a_milliwatt_hour', 'energy_b_milliwatt_hour', 'power_a_milliwatt', 'power_b_milliwatt'].each do |key|
      if document[key]
        value = document[key] * factor
        value * -1 if negativ
        item.merge!(key => value)
      end
    end
    return item
  end


  def external_data(metering_point, resolution, timestamp)
    puts '<================ external api call'
    crawler = Crawler.new(metering_point)

    case resolution
    when 'hour_to_minutes'
      results = crawler.hour(timestamp)
    when 'day_to_minutes'
      results = crawler.day(timestamp)
    when 'month_to_days'
      results = crawler.month(timestamp)
    when 'year_to_months'
      results = crawler.year(timestamp)
    end


    if results.first.size == 2 && metering_point.input?
      type_of_meter = 'in'
    elsif results.first.size == 2 && metering_point.output?
      type_of_meter = 'out'
    elsif results.first.size == 3 && metering_point.input?
      type_of_meter = 'in_out'
    end

    items = []
    results.each do |result|
      item = {'timestamp' => Time.at(result[0]/1000) }
      case type_of_meter
      when 'in'
        item.merge!('energy_a_milliwatt_hour' => (result[1]*1000).to_i)
      when 'out'
        item.merge!('energy_b_milliwatt_hour' => (result[1]*1000*-1).to_i)
      when 'in_out'
        item.merge!('energy_a_milliwatt_hour' => (result[1]*1000).to_i)
        item.merge!('energy_b_milliwatt_hour' => (result[2]*1000*-1).to_i)
      end
      items << item
    end

    return items
  end



end
