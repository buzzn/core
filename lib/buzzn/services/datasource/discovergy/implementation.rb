require_relative '../discovergy'

class Services::Datasource::Discovergy::Implementation < Buzzn::DataSource

  include Import['service.datasource.discovergy.last_reading']
  include Import['service.data_source_registry']

  NAME = :discovergy

  def initialize(**)
    super
    data_source_registry.add_source(self)
  end

  def single_aggregated(register_or_group, mode)
    if register_or_group.is_a?(Register::Base) && register_or_group.attributes['direction'] == mode
      last_reading.power(register_or_group)
    end
  end

  def collection(resource, mode)
    nil
  end

  def aggregated(resource, mode, interval)
    nil
  end
end
