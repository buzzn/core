require_relative '../discovergy'

class Services::Datasource::Discovergy::Throughput

  include Import['service.redis']

  NAME = 'discovergy.throughput'
  MAX_CONCURRENT_CONNECTIONS = 30

  def increment
    @redis.incr(NAME)
  end

  def increment!
    increment
    if current > MAX_CONCURRENT_CONNECTIONS
      raise Buzzn::DataSourceError.new('discovergy limit reached')
    end
  end

  def decrement
    @redis.decr(NAME)
  end

  def current
    @redis.get(NAME).to_i
  end

  def clear
    @redis.set(NAME, 0)
  end
end