module Buzzn::Discovergy
  class Throughput

    # TODO use redis instead and make thread-safe

    def initialize
      @counter = 0
    end

    def increment
      @counter += 1
    end

    def decrement
      @counter -= 1
    end

    def current
      @counter
    end
  end
end
