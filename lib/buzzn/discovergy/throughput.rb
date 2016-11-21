module Buzzn::Discovergy
  class Throughput

    NAME = 'discovergy.throughput'

    def initialize(redis = Redis.current)
      @redis = redis
    end

    def increment
      @redis.incr(NAME)
    end

    def decrement
      @redis.decr(NAME)
    end

    def current
      @redis.get(NAME)
    end

    def clear
      @redisset(NAME, 0)
    end
  end
end
