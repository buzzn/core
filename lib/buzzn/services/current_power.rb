require_relative '../services'

class Services::CurrentPower

  include Import['services.cache',
                 timetolive: 'config.datasource_timetolive_current',
                 registry: 'services.datasource.registry']

  def ticker(register)
    key = "ticker.#{register.id}"
    cache.get(key) || cached_ticker(key, register)
  end

  def bubbles(group)
    key = "bubbles.#{group.id}"
    cache.get(key) || cached_bubbles(key, group)
  end

  private

  def time_to_live
    @_ttl ||= timetolive.to_i
  end

  def cached_ticker(key, register)
    if result = registry.get(register.datasource).ticker(register)
      cache.put(key, result.to_json, time_to_live)
    end
  end

  def cached_bubbles(key, group)
    bubbles = []
    registry.each do |datasource|
      if result = datasource.bubbles(group)
        bubbles += result
      end
    end
    cache.put(key, bubbles.to_json, time_to_live)
  end

end
