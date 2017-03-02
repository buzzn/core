module Buzzn::Virtual

  class DataSource < Buzzn::DataSource

    NAME = :virtual

    def initialize(registry = nil)
      @registry = registry
    end

    def collection(resource, mode)
      return nil if resource.is_a? Group::Base
      # TODO handle register case
      nil
    end

    def single_aggregated(resource, mode)
      return nil if resource.is_a? Group::Base
      sum = 0
      timestamp = 0
      resource.formula_parts.each do |formula_part|
        mode = formula_part.operand.direction
        data = @registry.get(formula_part.operand.data_source).single_aggregated(formula_part.operand, mode)
        # be a bit more lenient with the offset as we do have network latencies 
        if timestamp == 0 || (timestamp - data.timestamp).abs < 6
          timestamp = data.timestamp
          formula_part.operator == '+' ? sum += data.value : sum -= data.value
        else
          raise Buzzn::DataSourceError.new('Timestamp mismatch at virtual register power calculation')
        end
      end
      Buzzn::DataResult.new(timestamp || Time.current, sum >= 0 ? sum : 0, resource.id, resource.direction)
    end

    def aggregated(resource, mode, interval)
      return nil if resource.is_a? Group::Base
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
