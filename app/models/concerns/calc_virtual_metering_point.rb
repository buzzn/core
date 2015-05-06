module CalcVirtualMeteringPoint
  extend ActiveSupport::Concern

  protected

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