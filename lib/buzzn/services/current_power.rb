require_relative '../services'

class Services::CurrentPower

  include Import.args[registry: 'service.data_source_registry']

  def ticker(register)
    registry.get(register.data_source).ticker(register)
  end
  alias :for_register :ticker

  def bubbles(resource)
    if resource.respond_to?(:object)
      group = resource.object
    else
      group = resource
    end
    raise ArgumentError.new("not a #{Group::Base}") unless group.is_a?(Group::Base)
    result = Buzzn::DataResultArray.new(0)
    registry.each do |data_source|
      result += data_source.collection(group, 'in')
      result += data_source.collection(group, 'out')
    end
    result.freeze unless result.frozen?
    result
  end
  alias :for_each_register_in_group :bubbles

  def for_group(resource)
    if resource.respond_to?(:object)
      group = resource.object
    else
      group = resource
    end
    raise ArgumentError.new("not a #{Group::Base}") unless group.is_a?(Group::Base)
    sum_in, sum_out = 0, 0
    registry.each do |data_source|
      result =  data_source.single_aggregated(group, 'in')
      sum_in += result.value if result
      result = data_source.single_aggregated(group, 'out')
      sum_out += result.value if result
    end
    result = Buzzn::InOutDataResults.new(Time.current, sum_in, sum_out, group.id)
    result.freeze unless result.frozen?
    result
  end
end
