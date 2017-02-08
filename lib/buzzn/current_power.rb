module Buzzn

  class CurrentPower

    def initialize(data_source_registry)
      @registry = data_source_registry
    end

    def for_register(register, timestamp = nil)
      raise ArgumentError.new("not a #{Register::Base}") unless register.is_a?(Register::Base)
      raise ArgumentError.new("not a #{Time}") if !(timestamp.is_a?(Time) || timestamp.nil?)
      # TODO something with the timestamp
      if register.is_a?(Register::Virtual)
        sum = 0
        register.formula_parts.each do |formula_part|
          mode = formula_part.operand.direction
          data = @registry.get(formula_part.operand.data_source).single_aggregated(formula_part.operand, mode)
          #TODO: check timestamp to match
          formula_part.operator == '+' ? sum += data.value : sum -= data.value
        end
        result = Buzzn::DataResult.new(timestamp || Time.current, sum, register.id, register.direction)
        return result
      else
        mode = register.is_a?(Register::Input)? :in : :out
        @registry.get(register.data_source).single_aggregated(register, mode)
      end
    end

    def for_each_register_in_group(group, timestamp = nil)
      raise ArgumentError.new("not a #{Group::Base}") unless group.is_a?(Group::Base)
      raise ArgumentError.new("not a #{Time}") if !(timestamp.is_a?(Time) || timestamp.nil?)
      # TODO something with the timestamp
      result = []
      @registry.each do |key, data_source|
        [:in, :out].each do |mode|
          more = data_source.collection(group, mode)
          result += more if more
        end
      end
      result
    end

    def for_group(group, timestamp = nil)
      raise ArgumentError.new("not a #{Group::Base}") unless group.is_a?(Group::Base)
      raise ArgumentError.new("not a #{Time}") if !(timestamp.is_a?(Time) || timestamp.nil?)
      # TODO something with the timestamp
      sum_in, sum_out = 0, 0
      @registry.each do |key, data_source|
        result =  data_source.single_aggregated(group, :in)
        binding.pry
        sum_in += result.value if result
        result = data_source.single_aggregated(group, :out)
        sum_out += result.value if result
      end
      Buzzn::InOutDataResults.new(timestamp || Time.current, sum_in, sum_out, group.id)
    end
  end
end
