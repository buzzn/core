module Buzzn
  class DataPoint
    attr_reader :timestamp, :value

    def self.from_hash(data)
      new(data[:timestamp], data[:value])
    end
          
    def initialize(timestamp, value)
      @timestamp = timestamp
      @value = value
    end

    def add(other)
      @value += other.value if other
    end

    def to_hash
      { timestamp: @timestamp, value: @value }
    end
  end
end
