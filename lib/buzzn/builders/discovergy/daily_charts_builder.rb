require_relative 'abstract_registers_builder'

module Builders::Discovergy
  class DailyChartsBuilder < AbstractRegistersBuilder

    FIXNUM_MAX = 4294967296

    def build(response)
      consumption = {}
      production = {}
      min = FIXNUM_MAX
      build_method = build_method(response)
      response.each do |id, data|
        next unless map.key?(id)
        next if data.empty?
        min = [min, data.size].min
        map[id].each do |register|
          build_method.call(register, consumption, production, data)
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

    def build_method(response)
      substitute = substitute_register(response)
      if substitute&.label&.consumption?
        method(:build_sum_with_consumption_substitute)
      elsif substitute&.label&.production?
        method(:build_sum_with_production_substitute)
      elsif has_virtual?
        method(:build_sum_with_consumption_substitute)
      else
        method(:build_sum)
      end
    end

    def substitute_register(response)
      response.find do |id, _|
        map[id].is_a?(Register::Substitute)
      end
    end

    BAD_METERS = %w(60009408 60009426 60009392 60009436 60009414 60009421 60009412 60009396 60009394 60009391 60009399 60009433 60009427 60009403 60009398 60009397 60009428 60009389 60009388 60009443 60009401 60009439 60009434 60009424 60009430 60009406 60009417 60009432 60009431 60009400 60009437 60300725 60668496 60668498 60668494 60668497 60668493 60668495 60668492)
    def has_virtual?
      registers.find do |register|
        BAD_METERS.include?(register.meter.product_serialnumber) &&
          register.label.consumption?
      end
    end

    def truncate(set, min)
      set.delete(set.keys.last) while set.size > min
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
      elsif register.label.consumption?
        do_sum(register, consumption, data)
      else
        # ignored
      end
    end

    def build_sum_with_consumption_substitute(register, consumption, production, data)
      if register.grid_consumption?
        do_sum(register, consumption, data)
      elsif register.grid_feeding?
        do_sum(register, consumption, data, method(:substract))
      elsif register.label.production?
        do_sum(register, consumption, data)
        do_sum(register, production, data)
      end
    end

    def build_sum_with_production_substitute(register, consumption, production, data)
      if register.grid_consumption?
        do_sum(register, production, data)
      elsif register.grid_feeding?
        do_sum(register, production, data, method(:substract))
      elsif register.label.consumption?
        do_sum(register, consumption, data)
        do_sum(register, production, data)
      end
    end

    def add(a, b)
      a + b
    end

    def substract(a, b)
      a - b
    end

    def do_sum(register, result, data, aggregate_method = method(:add))
      data.each do |item|
        time = item['time']
        result[time] ||= 0
        result[time] = aggregate_method.call(result[time], to_watt_hour(item, register))
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
end
