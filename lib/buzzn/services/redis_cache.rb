require_relative '../services'
require 'redis'

class Services::RedisCache

  include Import['config.redis_cache_url']

  def create
    ::Redis.new(url: redis_cache_url)
  end

  # just factory method for Redis
  def self.new
    @instance ||= super().create
  end

end
