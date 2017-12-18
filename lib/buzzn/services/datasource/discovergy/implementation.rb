require_relative '../discovergy'

class Services::Datasource::Discovergy::Implementation < Buzzn::DataSource

  include Import['service.datasource.discovergy.last_reading',
                 'service.data_source_registry']

  NAME = :discovergy

  def initialize(**)
    super
    data_source_registry.add_source(self)
  end

  def ticker(register)
    last_reading.power(register)
  end

  def bubbles(group)
    last_reading.power_collection(group)
  end

  def aggregated(resource, mode, interval)
    nil
  end
end
