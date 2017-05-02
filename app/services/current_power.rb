module Buzzn::Services

  class CurrentPower
    include Import.args[registry: 'service.data_source_registry']

    def for_register(resource)
      raise ArgumentError.new("not a #{Register::BaseResource}") if !resource.is_a?(Register::BaseResource) && !resource.is_a?(Register::Base)
      if resource.is_a?(Register::BaseResource)
        register = resource.object
      else
        register = resource
      end
      result = registry.get(register.data_source).single_aggregated(register, register.direction)
      result.freeze unless result.frozen?
      result
    end

    def for_each_register_in_group(resource)
      raise ArgumentError.new("not a #{Group::MinimalBaseResource}") unless resource.is_a?(Group::MinimalBaseResource)
      group = resource.object
      result = Buzzn::DataResultArray.new(0)
      registry.each do |data_source|
        result += data_source.collection(group, :in)
        result += data_source.collection(group, :out)
      end
      result.freeze unless result.frozen?
      result
    end

    def for_group(resource)
      raise ArgumentError.new("not a #{Group::MinimalBaseResource}") unless resource.is_a?(Group::MinimalBaseResource)
      group = resource.object
      sum_in, sum_out = 0, 0
      registry.each do |data_source|
        result =  data_source.single_aggregated(group, :in)
        sum_in += result.value if result
        result = data_source.single_aggregated(group, :out)
        sum_out += result.value if result
      end
      result = Buzzn::InOutDataResults.new(Time.current, sum_in, sum_out, group.id)
      result.freeze unless result.frozen?
      result
    end
  end
end
