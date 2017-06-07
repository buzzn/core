class Buzzn::Services::Redis
  include Import['secrets.redishost']

  def create
    ::Redis.new(host: redishost)
  end

  # just factory method for Redis
  def self.new
    @instance ||= super().create
  end
end
