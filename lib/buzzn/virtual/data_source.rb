module Buzzn::Virtual

  class DataSource < Buzzn::DataSource

    NAME = :virtual

    def initialize(registry = nil)
      @registry = registry
    end

    def collection(resource, mode)
      return nil if resource.is_a? Group
      # TODO handle register case
      nil
    end

    def single_aggregated(resource, mode)
      return nil if resource.is_a? Group
      sum = 0
      resource.formula_parts.each do |formula_part|
        mode = formula_part.operand.direction
        data = @registry.get(formula_part.operand.data_source).single_aggregated(formula_part.operand, mode)
        #TODO: check timestamp to match
        formula_part.operator == '+' ? sum += data.value : sum -= data.value
      end
      Buzzn::DataResult.new(timestamp || Time.current, sum, resource.id, resource.direction)
    end

    def aggregated(resource, mode, interval)
      return nil if resource.is_a? Group
      units = interval.hour? || interval.day? ? :milliwatt : :milliwatt_hour
      result = Buzzn::DataResultSet.send(units, resource.id)
      resource.formula_parts.each do |formula_part|
        mode = formula_part.operand.direction
        data = @registry.get(formula_part.operand.data_source).aggregated(formula_part.operand, mode, interval)
        formula_part.operator == '+' ? result.add_all(data, interval.duration) : result.subtract_all(data, interval.duration)
      end
      result.combine(resource.direction, interval.duration)
      return result
    end
  end
end
