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
      metering_point.each do |reading|
        if i == 0
          timestamps << reading[0]
          watts << reading[1]
        else
          if data[i - 1].empty? && timestamps[j].nil?
            timestamps << reading[0]
            watts << reading[1]
          else
            indexOfTimestamp = get_matching_index(timestamps, reading[0], resolution)
            if indexOfTimestamp
              if operators[i] == "+"
                watts[indexOfTimestamp] += reading[1]
              elsif operators[i] == "-"
                watts[indexOfTimestamp] -= reading[1]
              elsif operators[i] == "*"
                watts[indexOfTimestamp] *= reading[1]
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




  def convert_to_array(data, resolution_format)
    hours = []
    data.each do |hour|
      if resolution_format == :year_to_months || resolution_format == :month_to_days
        hours << [
          hour['firstTimestamp'].to_i*1000,
          hour['consumption'].to_i/10000000000.0
        ]
      else
        hours << [
          hour['firstTimestamp'].to_i*1000,
          hour['avgPower'].to_i/1000
        ]
      end
    end
    return hours
  end


  def convert_to_array_build_timestamp(data, resolution_format, containing_timestamp)
    hours = []
    time = Time.at(containing_timestamp.to_i/1000)
    year = time.year
    month = time.month

    data.each do |value|
      if resolution_format == :hour_to_minutes || resolution_format == :day_to_minutes
        day = time.day
        hour = value[:_id][:hourly]
        minute = value[:_id][:minutely]
        timestamp = Time.new(year, month, day, hour, minute, 0)
      elsif resolution_format == :day_to_hours
        day = time.day
        hour = value[:_id][:hourly]
        timestamp = Time.new(year, month, day, hour, 0, 0)
      elsif resolution_format == :month_to_days
        day = value[:_id][:dayly]
        timestamp = Time.new(year, month, day, 0, 0, 0)
      elsif resolution_format == :year_to_months
        month = value[:_id][:monthly]
        timestamp = Time.new(year, month, 1, 0, 0, 0)
      end


      if resolution_format == :year_to_months || resolution_format == :month_to_days
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
    if resolution.to_s == "day_to_hours"
      offset = 30*1000
    elsif resolution.to_s == "month_to_days"
      offset = 12*60*60*1000
    elsif resolution.to_s == "year_to_months"
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