require_relative '../discovergy'

class Services::Datasource::Discovergy::Implementation

  extend Dry::DependencyInjection::Eager

  include Import['services.datasource.discovergy.last_reading',
                 'services.datasource.discovergy.charts',
                 'services.datasource.registry']

  NAME = :discovergy

  def initialize(**)
    super
    registry.add_source(self)
  end

  def ticker(register)
    last_reading.power(register)
  end

  def bubbles(group)
    last_reading.power_collection(group)
  end

  def daily_charts(group)
    charts.daily(group)
  end

  # old and probably obsolete

  def aggregated(resource, mode, interval)
    nil
  end

end
