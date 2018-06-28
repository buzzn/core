require_relative '../services'
require 'redis'

class Services::RedisSidekiq

  include Import['config.redis_sidekiq_url']

  def create
    ::Redis.new(url: redis_sidekiq_url)
  end

  # just factory method for Redis
  def self.new
    @instance ||= super().create
  end

end
