require 'leafy/core/gauge'
require 'concurrent'
require_relative '../discovergy'
require 'buzzn/data_source_error'

class Services::Datasource::Discovergy::Throughput

  include Import['service.redis', 'service.metrics']

  NAME = 'discovergy.throughput'
  MAX_CONCURRENT_CONNECTIONS = 30

  def initialize(**)
    super
    @throughput = Leafy::Core::Gauge.new
    @throughput.value = 0
    metrics.register(NAME, @throughput)
  end

  def increment
    @throughput.value = @redis.incr(NAME)
  end

  def increment!
    if current == MAX_CONCURRENT_CONNECTIONS
      raise Buzzn::DataSourceError.new('discovergy limit reached')
    end
    increment
    true
  end

  def decrement
    @throughput.value = @redis.decr(NAME)
  end

  def current
    @redis.get(NAME).to_i
  end

  def clear
    @redis.set(NAME, 0)
  end
end
