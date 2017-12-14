require_relative '../services'

class Services::CurrentPower

  include Import[registry: 'service.data_source_registry']
  include Import['service.cache']

  TIME_TO_LIVE = 15

  def ticker(register)
    key = "ticker.#{register.id}"
    cache.get(key) || cached_ticker(key, register)
  end

  def bubbles(group)
    key = "bubbles.#{group.id}"
    cache.get(key) || cached_bubbles(key, group)
  end

  def for_group(resource)
    raise 'not implemented anymore'
  end

  private

  def cached_ticker(key, register)
    if result = registry.get(register.data_source).ticker(register)
      cache.put(key, result.to_json, TIME_TO_LIVE)
    end
  end

  def cached_bubbles(key, group)
    bubbles = []
    registry.each do |datasource|
      if result = datasource.bubbles(group)
        bubbles += result
      end
    end
    cache.put(key, bubbles.to_json, TIME_TO_LIVE)
  end
end
