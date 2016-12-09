module Buzzn

  class CurrentPower

    def initialize(data_source_registry)
      @registry = data_source_registry
    end

    def for_register(register)
      mode = register.is_a?(Register::Input)? :in : :out
      @registry.get(register.data_source).aggregated(register, interval, mode)
    end

    def for_group(group)
      result = []
      @registry.each do |key, data_source|
        [:in, :out].each do |mode|
          result += data_source.collection(group, interval, mode)
        end
      end
      result
    end

    def for_group_aggregated(group)
      sum_in, sum_out = 0, 0
      @registry.each do |key, data_source|
        result =  data_source.aggregated(group, interval, :in)
        sum_in += result.value if result
        result = data_source.aggregated(group, interval, :out)
        sum_out += result.value if result
      end
      Buzzn::DataResults.new(group.id, Time.current, sum_in, sum_out)
    end
  end
end
