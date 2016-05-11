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

  def chart(chart_params = {})
    seconds_to_process = Benchmark.realtime do
      @chart_items = []
      timestamp  = chart_params.fetch(:timestamp, Time.now.in_time_zone) || Time.now.in_time_zone
      resolution = chart_params.fetch(:resolution, 'day_to_hours') || 'day_to_hours'

      # sorting metering_points
      buzzn_reader_metering_points  = []
      discovergy_metering_points    = []
      slp_metering_points           = []
      MeteringPoint.where(id: @metering_point_ids).each do |metering_point|

        case metering_point.data_source
        when 'buzzn-reader'
          buzzn_reader_metering_points << metering_point
        when 'discovergy'
          discovergy_metering_points << metering_point
        when 'slp'
          slp_metering_points << metering_point
        else
          "You gave me #{a} -- I have no idea what to do with that."
        end

      end

      # buzzn_reader
      if buzzn_reader_metering_points.any?
        collection = Reading.aggregate(resolution, buzzn_reader_metering_points.collect(&:id), timestamp.to_i*1000)
        @chart_items << convert_to_array(collection, resolution, 1)
      end

      # discovergy
      discovergy_metering_points.each do |metering_point|
        @chart_items << external_chart_data(metering_point, resolution, timestamp.to_i*1000)
      end

      #slp
      if slp_metering_points.any?
        collection = Reading.aggregate(resolution, ['slp'], timestamp)
        @chart_items << convert_to_array(collection, resolution, 1)
      end

      @chart = calculate_virtual_metering_point(@chart_items, Array.new(@chart_items.count, "+"), resolution)
    end



    # if seconds_to_process > 2
    # else
    # end

    return @chart
  end


private

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
