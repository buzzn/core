module Buzzn

  class CurrentPower

    def initialize(data_source_registry)
      @registry = data_source_registry
    end

<<<<<<< d5ce39dd6217b325740feed7bd27a6c6df2ba45c
    def for_register(register, timestamp = nil)
      # TODO something with the timestamp
=======
    def for_register(register)
>>>>>>> API cleanup, concrete result value object
      mode = register.is_a?(Register::Input)? :in : :out
      @registry.get(register.data_source).aggregated(register, mode)
    end

<<<<<<< d5ce39dd6217b325740feed7bd27a6c6df2ba45c
    def for_each_register_in_group(group, timestamp = nil)
      # TODO something with the timestamp
=======
    def for_group(group)
>>>>>>> API cleanup, concrete result value object
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
      Buzzn::DataResults.new(timestamp || Time.current,
                             sum_in, sum_out, group.id)
    end
  end
end
