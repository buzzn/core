class Buzzn::Services::Redis

  def create
    ::Redis.new(url: Import.global('config.redis_url'))
  end

  # just factory method for Redis
  def self.new
    @instance ||= super().create
  end
end
