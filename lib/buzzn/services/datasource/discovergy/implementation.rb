require_relative '../discovergy'

class Services::Datasource::Discovergy::Implementation < Buzzn::DataSource

  include Import['service.datasource.discovergy.last_reading']
  include Import['service.data_source_registry']

  NAME = :discovergy

  def initialize(**)
    super
    data_source_registry.add_source(self)
  end

  def ticker(register)
    key = "discovergy.ticker.power.#{register.id}"
    cache.get(key) || cache.set(key, last_reading.power(register).to_json, 15)
  end

  def collection(resource, mode)
    nil
  end

  def aggregated(resource, mode, interval)
    nil
  end
end
