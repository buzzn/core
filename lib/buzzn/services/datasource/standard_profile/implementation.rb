require_relative '../standard_profile'

class Services::Datasource::StandardProfile::Implementation < Buzzn::DataSource

  include Import['service.data_source_registry']

  NAME = :standard_profile

  def initialize(**)
    super
    data_source_registry.add_source(self)
  end

  def single_aggregated(register_or_group, mode)
    nil
  end

  def collection(resource, mode)
    nil
  end

  def aggregated(resource, mode, interval)
    nil
  end
end
