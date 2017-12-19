require_relative '../types/cache_item'

class Services::Cache

  include Import['service.redis']

  def put(key, json, time_to_live)
    item = Types::CacheItem.new(json: json, time_to_live: time_to_live)
    redis.set(key, json, ex: time_to_live)
    redis.set(digest_key(key), item.digest, ex: time_to_live)
    item
  end

  def get(key)
    if (time_to_live = redis.ttl(key)) > 0
      json, digest = redis.mget(key, digest_key(key))
      Types::CacheItem.new(json: json, digest: digest, time_to_live: time_to_live)
    end
  end

  private

  def digest_key(key)
    "#{key}.digest"
  end
end