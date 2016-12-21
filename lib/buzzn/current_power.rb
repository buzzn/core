module Buzzn

  class CurrentPower

    def initialize(data_source_registry)
      @registry = data_source_registry
    end

    def for_register(register, timestamp = nil)
      raise ArgumentError.new("not a #{Register::Base}") unless register.is_a?(Register::Base)
      raise ArgumentError.new("not a #{Time}") if !(timestamp.is_a?(Time) || timestamp.nil?)
      # TODO something with the timestamp
      mode = register.is_a?(Register::Input)? :in : :out
      @registry.get(register.data_source).single_aggregated(register, mode)
    end

    def for_each_register_in_group(group, timestamp = nil)
      raise ArgumentError.new("not a #{Group}") unless group.is_a?(Group)
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
      raise ArgumentError.new("not a #{Group}") unless group.is_a?(Group)
      raise ArgumentError.new("not a #{Time}") if !(timestamp.is_a?(Time) || timestamp.nil?)
      # TODO something with the timestamp
      sum_in, sum_out = 0, 0
      @registry.each do |key, data_source|
        result =  data_source.single_aggregated(group, :in)
        sum_in += result.value if result
        result = data_source.single_aggregated(group, :out)
        sum_out += result.value if result
      end
      Buzzn::InOutDataResults.new(timestamp || Time.current,
                                  sum_in, sum_out, group.id)
    end
  end
end
