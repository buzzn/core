# ********* examples how to use **********
#
# metering_point = MeteringPoint.create(mode: 'in', virtual: true, name: 'test', readable: 'world')
# metering_point_a = MeteringPoint.first
# metering_point_b = MeteringPoint.last

# chart_1 = metering_point_1.chart_data('day_to_minutes', Time.now.to_i*1000)
# chart_2 = metering_point_2.chart_data('day_to_minutes', Time.now.to_i*1000)
# final_chart = metering_point.calculate_virtual_metering_point([chart_1, chart_2], ['+', '-'], 'day_to_minutes')





module CalcVirtualMeteringPoint
  extend ActiveSupport::Concern


  # input paramters:
  #   data: the energy data as array that has to be aggregated, e.g. [[[1456123, 44], [1456124, 55], [1456125, 43]], [[1456123, 440], [1456124, 505], [1456125, 403]]]
  #   operators: the operators as array that define how to aggregate the data, e.g. ['+', '-']
  #   resolution: the resolution of the aggregated data to determine the time distance between each data point
  # output paramters:
  #   result: the energy data as array, e.g. [[1456123, 484], [1456124, 560], [1456125, 446]]
  def calculate_virtual_metering_point(data, operators, resolution)

    timestamps = []
    watts = []
    i = 0
    data.each do |metering_point|
      j = 0
      if metering_point.empty?
        i += 1
        next
      end
      metering_point = insert_new_mesh(metering_point, resolution)
      metering_point.each do |reading|
        if i == 0
          timestamps << reading[0]
          watts << reading[1]
        else
          if timestamps[j].nil?
            timestamps << reading[0]
            watts << reading[1]
          else
            indexOfTimestamp = get_matching_index(timestamps, reading[0], resolution)
            if indexOfTimestamp
              if operators[i] == "+"
                watts[indexOfTimestamp] += reading[1]
              elsif operators[i] == "-"
                watts[indexOfTimestamp] -= reading[1]
              end
            end
          end
        end
        j += 1
      end
      i += 1
    end
    result = []
    for i in 0...watts.length
      result << [
        timestamps[i],
        watts[i]
      ]
    end
    return result
  end


  # this function analyzes the incoming data and calculates the new datapoints defined by resolution
  # input paramters:
  #   data: the energy data as array that has to be aggregated, e.g. [[[1456123, 44], [1457123, 55], [1458123, 43]], [[1456123, 440], [1457123, 505], [1458123, 403]]]
  #   resolution: the resolution of the aggregated data to determine the time distance between each data point
  # output paramters:
  #   result: the energy data as array, e.g. [[[1456123, 44], [1456124, 55], [1456125, 43]], [[1456123, 440], [1456124, 505], [1456125, 403]]]
  def insert_new_mesh(data, resolution)
    result = []
    if resolution == "day_to_minutes"
      firstTimestamp = (Time.at(data[0][0]/1000).in_time_zone).beginning_of_minute
      lastTimestamp = firstTimestamp.end_of_day.in_time_zone
      offset = 60 * 1000
    elsif resolution == "hour_to_minutes"
      firstTimestamp = (Time.at(data[0][0]/1000).in_time_zone).beginning_of_minute
      lastTimestamp = firstTimestamp.end_of_hour.in_time_zone
      offset = 60 * 1000
    elsif resolution == "year_to_months"
      data.each do |reading|
        #puts reading
        result << [Time.at(reading[0]/1000).in_time_zone.beginning_of_month.to_i*1000, reading[1]]
      end
      return result
    else
      return data
    end
    new_timestamp = firstTimestamp.to_i*1000
    new_reading = 0
    count_readings = 0
    sum_readings = 0
    i = 0
    j = 0
    while firstTimestamp.to_i*1000 + j * offset <= lastTimestamp.to_i*1000 && i < data.size
      if data[i][0] - new_timestamp <= offset
        count_readings += 1
        sum_readings += data[i][1]
      else
        if count_readings != 0
          new_reading = (sum_readings*1.0 / count_readings).to_i
          result << [new_timestamp, new_reading]
          count_readings = 0
          sum_readings = 0
        else
          result << [new_timestamp, new_reading]
        end
        new_timestamp += offset
        j += 1
        i -= 1
      end
      i += 1
    end
    if count_readings != 0
      new_reading = (sum_readings*1.0 / count_readings).to_i
      result << [new_timestamp, new_reading]
      count_readings = 0
      sum_readings = 0
    else
      result << [new_timestamp, new_reading]
    end
    return result
  end




  def convert_to_array(data, resolution_format, factor)
    hours = []
    data.each do |hour|
      if resolution_format == 'year_to_months' || resolution_format == 'month_to_days' || resolution_format == 'year' || resolution_format == 'month' || resolution_format == 'day'
        hours << [
          hour['firstTimestamp'].to_i*1000,
          hour['consumption'].to_i/10000000000.0 * factor
        ]
      else
        hours << [
          hour['firstTimestamp'].to_i*1000,
          hour['avgPower'].to_i/1000 * factor
        ]
      end
    end
    return hours
  end





  def convert_to_array_build_timestamp(data, resolution_format, containing_timestamp)
    hours = []

    data.each do |value|

      timestamp = Time.utc(
        value[:_id][:yearly]   || 2000,
        value[:_id][:monthly]  || 1,
        value[:_id][:dayly]    || 1,
        value[:_id][:hourly]   || 0,
        value[:_id][:minutely] || 0,
        value[:_id][:secondly] || 0
      )

      if resolution_format == 'year_to_months' || resolution_format == 'month_to_days' || resolution_format == 'year' || resolution_format == 'month' || resolution_format == 'day'
        hours << [
          timestamp.to_i*1000,
          value['consumption'].to_i/10000000000.0
        ]
      else
        hours << [
          timestamp.to_i*1000,
          value['avgPower'].to_i/1000
        ]
      end

    end
    return hours
  end




  private

  # this function is looking for the index of a special value in an array.
  # If the value is not in the array it returns the next index dependent on the resolution
  # input paramters:
  #   arr: the array containing timestamps
  #   value: the timestamp for which the function is searching the index
  #   resolution: the resolution of the data to determine the time distance between each data point
  # output paramters:
  #   result: the (next) index of the value in arr
  def get_matching_index(arr, value, resolution)
    offset = 1000
    if resolution == "day_to_minutes"
      offset = 30*1000
    elsif resolution == "day_to_hours"
      offset = 30*60*1000
    elsif resolution == "month_to_days"
      offset = 12*60*60*1000
    elsif resolution == "year_to_months"
      offset = 15*24*60*60*1000
    end

    result = arr.index(value)
    if result
      return result
    end
    i = 0
    length = arr.length
    while i < length
      if (value - arr[i]).abs <= offset
        return i
      end
      i+=1
    end
  end
end