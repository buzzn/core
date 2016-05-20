#
# aggregator = Aggregator.new()
# aggregator.chart
#


require 'benchmark'
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
          reading = Reading.where(metering_point_id: metering_point.id, :timestamp.gte => @timestamp).last
          @power_items << reading.power_milliwatt
        end

        # discovergy
        discovergy_metering_points.each do |metering_point|
          @power_items << external_chart_data(metering_point, @resolution, @timestamp.to_i*1000)
        end

        #slp
        if slp_metering_points.any?
          reading = Reading.where(:timestamp.gte => (@timestamp - 15.minutes), :timestamp.lte => (@timestamp + 15.minutes), source: 'slp').last
          slp_metering_points.each do |metering_point|
            factor = metering_point.forecast_kwh_pa ? (metering_point.forecast_kwh_pa/900.0) : 1
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
          collection = Reading.aggregate(@resolution, buzzn_api_metering_points.collect(&:id), @timestamp.in_time_zone)
          @chart_items << convert_to_array(collection, @resolution, 1)
        end

        # discovergy
        discovergy_metering_points.each do |metering_point|
          @chart_items << external_chart_data(metering_point, @resolution, @timestamp.to_i*1000)
        end

        #slp
        if slp_metering_points.any?
          collection = Reading.aggregate(@resolution, ['slp'], @timestamp)
          slp_metering_points.each do |metering_point|
            factor = metering_point.forecast_kwh_pa ? (metering_point.forecast_kwh_pa/900.0) : 1
            @chart_items << convert_to_array(collection, @resolution, factor)
          end
        end

        @chart = calculate_virtual_metering_point(@chart_items, Array.new(@chart_items.count, "+"), @resolution)
      end
      if seconds_to_process > 2
        Rails.cache.write(@cache_id, @chart, expires_in: 1.minute)
      end
    end
    return @chart
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


  def external_chart_data(metering_point, resolution, timestamp)
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
    return result
  end



end
