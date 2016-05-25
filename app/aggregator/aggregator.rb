#
# aggregator = Aggregator.new()
# aggregator.chart
#


require 'benchmark'
require 'matrix'
class Aggregator
  include CalcVirtualMeteringPoint

  attr_accessor :metering_point_ids, :charts

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

        # buzzn_api
        # TODO sum this in mongodb.
        buzzn_api_metering_points.each do |metering_point|
          reading = Reading.where(meter_id: metering_point.meter.id, :timestamp.gte => @timestamp).last
          @power_items << reading.power_milliwatt
        end

        # discovergy
        discovergy_metering_points.each do |metering_point|
          @power_items << external_data(metering_point, @resolution, @timestamp.to_i*1000)
        end

        #slp
        if slp_metering_points.any?
          reading = Reading.where(:timestamp.gte => (@timestamp - 15.minutes), :timestamp.lte => (@timestamp + 15.minutes), source: 'slp').last
          slp_metering_points.each do |metering_point|
            factor = metering_point.forecast_kwh_pa ? (metering_point.forecast_kwh_pa/1000) : 1
            @power_items << reading.power_milliwatt * factor
          end
        end
      end
    end

    @power = @power_items.inject(0, :+)

    if seconds_to_process > 2
      Rails.cache.write(@cache_id, @power, expires_in: 5.seconds)
    end

    return @power
  end




  def chart(params = {})
    @cache_id = "/aggregate/chart?metering_point_ids=#{@metering_point_ids.join(',')}&timestamp=#{@timestamp}&resolution=#{@resolution}"

    if Rails.cache.exist?(@cache_id)
      @chart = Rails.cache.fetch(@cache_id)
    else
      seconds_to_process = Benchmark.realtime do
        @chart_items = []
        @timestamp  = params.fetch(:timestamp, Time.current) || Time.current
        @resolution = params.fetch(:resolution, 'day_to_hours') || 'day_to_hours'

        buzzn_api_metering_points, discovergy_metering_points, slp_metering_points = metering_points_sort(@metering_point_ids)

        # buzzn_api
        if buzzn_api_metering_points.any?
          collection = Reading.aggregate(@resolution, buzzn_api_metering_points.collect(&:meter_id), @timestamp)
          @chart_items << collection_to_hash(collection)
          #@chart_items << convert_to_array(collection, @resolution, 1)
        end

        # discovergy
        discovergy_metering_points.each do |metering_point|
          @chart_items << external_data(metering_point, @resolution, @timestamp.to_i*1000)
        end

        #slp
        if slp_metering_points.any?
          collection = Reading.aggregate(@resolution, ['slp'], @timestamp)
          slp_metering_points.each do |metering_point|
            factor = metering_point.forecast_kwh_pa ? (metering_point.forecast_kwh_pa/1000) : 1
            @chart_items << {"operator"=>"+", "data"=> collection_to_hash(collection, factor)}
          end
        end

        @chart = aggregate(@chart_items, @resolution)

      end
      if seconds_to_process > 2
        Rails.cache.write(@cache_id, @chart, expires_in: 1.minute)
      end
    end
    return @chart
  end



  def aggregate(json, resolution)
    key = json.first['data'].first.keys.last.to_sym
    timestamps = []
    values = []
    i = 0
    json.each do |series|
      j = 0
      if series.empty? || series['data'].empty?
        i += 1
        next
      end
      final_series = insert_new_mesh(series['data'], resolution)
      final_series.each do |data_point|
        if i == 0
          timestamps << data_point[:timestamp]
          values << data_point[key]
        else
          if timestamps[j].nil?
            timestamps << data_point[:timestamp]
            values << data_point[key]
          else
            indexOfTimestamp = get_matching_index(timestamps, data_point[:timestamp], resolution)
            if indexOfTimestamp
              if series['operator'] == "+"
                values[indexOfTimestamp] += data_point[key]
              elsif series['operator'] == "-"
                values[indexOfTimestamp] -= data_point[key]
              end
            end
          end
        end
        j += 1
      end
      i += 1
    end
    result = []

    for i in 0...values.length
      result << {
        timestamp: timestamps[i],
        key => values[i]
      }
    end
    return result
  end










private


  def metering_points_sort(metering_point_ids)
    buzzn_api_metering_points     = []
    discovergy_metering_points    = []
    slp_metering_points           = []

    MeteringPoint.where(id: @metering_point_ids).each do |metering_point|
      case metering_point.data_source
      when 'buzzn-api'
        buzzn_api_metering_points << metering_point
      when 'discovergy'
        discovergy_metering_points << metering_point
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
      timestamp = document['firstTimestamp']
      power     = document['avgPowerMilliwatt'] * factor
      energy_a  = document['sumEnergyAMilliwattHour'] * factor
      energy_b  = document['sumEnergyBMilliwattHour'] * factor
      items << {
        'timestamp' => timestamp,
        'power_milliwatt' => power,
        'energy_a_milliwatt_hour' => energy_a,
        'energy_b_milliwatt_hour' => energy_b
      }
    end
    return items
  end

  def external_data(metering_point, resolution, timestamp)
    crawler = Crawler.new(metering_point)
    if resolution == 'hour_to_minutes'
      result = crawler.hour(timestamp)
    elsif resolution == 'day_to_minutes'
      result = crawler.day(timestamp)
    elsif resolution == 'month_to_days'
      result = crawler.month(timestamp)
    elsif resolution == 'year_to_months'
      result = crawler.year(timestamp)
    end

    # the rails view is using Crawler.rb dirctly. so i need to change the result later
    # TODO move this into Crawler.rb
    items = []
    result.each do |item|
      items << { timestamp: Time.at(item[0]/1000), power_milliwatt: item[1]*1000 }
    end

    return items
  end

  # data:
  # [{"timestamp"=>"2016-01-31T23:00:00.000Z", "power_milliwatt"=>930000.0},
  # {"timestamp"=>"2016-01-31T23:15:00.000Z", "power_milliwatt"=>930000.0},
  # {"timestamp"=>"2016-01-31T23:30:00.000Z", "power_milliwatt"=>930000.0},
  # {"timestamp"=>"2016-01-31T23:45:00.000Z", "power_milliwatt"=>930000.0}]
  def insert_new_mesh(data, resolution)
    result = []
    key = data.first.keys.last
    if resolution == "day_to_minutes"
      firstTimestamp = data.first['timestamp'].to_time.beginning_of_minute
      lastTimestamp = data.first['timestamp'].to_time.end_of_day
      offset = 60
    elsif resolution == "hour_to_minutes"
      firstTimestamp = data.first['timestamp'].to_time.beginning_of_minute
      lastTimestamp = data.first['timestamp'].to_time.end_of_hour
      offset = 60
    elsif resolution == "year_to_months"
      data.each do |reading|
        result << { timestamp: reading['timestamp'].beginning_of_month, "#{key}": reading[key]}
      end
      return result
    else
      return data
    end
    new_timestamp = firstTimestamp
    now = Time.now
    new_value = 0
    count_readings = 0
    sum_power = 0
    i = 0
    j = 0
    while firstTimestamp + j * offset < lastTimestamp && (now > lastTimestamp || i < data.size)
      if i < data.size && data[i]['timestamp'].to_time - new_timestamp <= offset
        count_readings += 1
        sum_power += data[i][key]
      else
        if count_readings != 0
          new_value = (sum_power*1.0 / count_readings).to_i
          result << { timestamp: new_timestamp, "#{key}": new_value }
          count_readings = 0
          sum_power = 0
        else
          result << { timestamp: new_timestamp, "#{key}": new_value }
        end
        new_timestamp += offset
        j += 1
        i -= 1
      end
      i += 1
    end
    if count_readings != 0
      new_value = (sum_power*1.0 / count_readings).to_i
      result << { timestamp: new_timestamp, "#{key}": new_value }
      count_readings = 0
      sum_power = 0
    else
      result << { timestamp: new_timestamp, "#{key}": new_value }
    end
    return result
  end


  def get_matching_index(arr, value, resolution)
    offset = 1
    if resolution == "day_to_minutes" || resolution == "hour_to_minutes"
      offset = 30
    elsif resolution == "day_to_hours"
      offset = 3600
    elsif resolution == "month_to_days"
      offset = 12*3600
    elsif resolution == "year_to_months"
      offset = 15*24*3600
    end

    result = arr.index(value)
    if result
      return result
    end
    i = 0
    length = arr.length
    while i < length
      if (value.to_time - arr[i].to_time).abs <= offset
        return i
      end
      i+=1
    end
  end




end
