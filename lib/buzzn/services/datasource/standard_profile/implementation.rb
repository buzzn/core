require_relative '../standard_profile'

class Services::Datasource::StandardProfile::Implementation < Buzzn::DataSource

  include Import['services.data_source_registry']

  NAME = :standard_profile

  def initialize(**)
    super
    data_source_registry.add_source(self)
  end

  def ticker(register)
    nil
  end

  def bubbles(group)
    nil
  end

  def daily_charts(group)
    nil
  end

  def aggregated(resource, mode, interval)
    nil
  end
end
