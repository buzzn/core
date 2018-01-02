require_relative '../services'

class Services::Redis
  include Import['config.redis_url']

  def create
    ::Redis.new(url: redis_url)
  end

  # just factory method for Redis
  def self.new
    @instance ||= super().create
  end
end
