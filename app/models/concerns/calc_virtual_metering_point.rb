module CalcVirtualMeteringPoint
  extend ActiveSupport::Concern



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