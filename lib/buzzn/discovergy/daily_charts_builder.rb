require_relative 'abstract_registers_builder'

class Discovergy::DailyChartsBuilder < Discovergy::AbstractRegistersBuilder

  FIXNUM_MAX = 4294967296

  def build(response)
    consumption = {}
    production = {}
    min = FIXNUM_MAX
    response.each do |id, data|
      if r = map[id] && data.size > 0
        min = [min, data.size].min
        build_sum(map[id], consumption, production, data)
      end
    end
    truncate(consumption, min)
    truncate(production, min)
    {
      consumption: build_response(consumption),
      production: build_response(production)
    }
  end

  private

  def truncate(set, min)
    while set.size > min
      set.delete(set.keys.last)
    end
  end

  def build_response(sums)
    {
      total: build_total(sums).to_i,
      data: build_charts(sums)
    }
  end

  def build_total(sums)
    sums.values[-1] - sums.values[1] unless sums.empty?
  end

  def build_sum(register, consumption, production, data)
    if register.label.production?
      do_sum(register, production, data)
    else
      do_sum(register, consumption, data)
    end
  end

  def do_sum(register, result, data)
    data.each do |item|
      time = item['time']
      result[time] ||= 0
      result[time] += to_watt_hour(item, register)
    end
  end

  def build_charts(sums)
    previous = sums.values.first
    return {} unless previous
    sums.entries[1..-1].each_with_object({}) do |entry, result|
      value = entry[1]
      result[entry[0]] = ((value - previous) * 20).to_i
      previous = value
    end
  end
end
