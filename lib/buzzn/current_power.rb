module Buzzn

  class CurrentPower

    def initialize(data_source_registry)
      @registry = data_source_registry
    end

    def for_register(register, timestamp = nil)
      # TODO something with the timestamp
      mode = register.is_a?(Register::Input)? :in : :out
      @registry.get(register.data_source).aggregated(register, mode)
    end

    def for_each_register_in_group(group, timestamp = nil)
      # TODO something with the timestamp
      result = []
      @registry.each do |key, data_source|
        [:in, :out].each do |mode|
          result += data_source.collection(group, mode)
        end
      end
      result
    end

    def for_group(group, timestamp = nil)
      # TODO something with the timestamp
      sum_in, sum_out = 0, 0
      @registry.each do |key, data_source|
        result =  data_source.aggregated(group, :in)
        sum_in += result.value if result
        result = data_source.aggregated(group, :out)
        sum_out += result.value if result
      end
      Buzzn::DataResults.new(group.id, timestamp || Time.current,
                             sum_in, sum_out)
    end
  end
end
