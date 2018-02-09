require_relative '../services'

class Services::Charts

  include Import[registry: 'services.datasource.registry']
  include Import['services.cache']

  TIME_TO_LIVE = 15 * 60 # seconds

  def daily(group)
    key = "charts.daily.#{group.id}"
    cache.get(key) || cached_daily(key, group)
  end

  private

  def cached_daily(key, group)
    registry.each do |datasource|
      if result = datasource.daily_charts(group)
        return cache.put(key, result.to_json, TIME_TO_LIVE)
      end
    end
    cache.put(key, '{}', TIME_TO_LIVE)
  end
end
