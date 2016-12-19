module Buzzn
  class DataPoint
    attr_reader :timestamp, :value

    def self.from_json(data)
      from_hash(JSON.parse(data, symbolize_names: true))
    end

    def self.from_hash(data)
      new(data[:timestamp], data[:value])
    end
          
    def initialize(timestamp, value)
      @timestamp = case timestamp
                   when Time
                     timestamp.to_f
                   when String
                     timestamp.to_f
                   when Fixnum
                     timestamp / 1000.0
                   when Float
                     timestamp
                   else
                     raise ArgumentError.new("timestamp not a Time or String or Fixnum or Float: #{timestamp.class}")
                   end
      @value = value.to_f
      raise 'value most not be negativ' if @value < 0
    end

    def add(other)
      raise ArgumentError.new('mismatch timestamp') if @timestamp != other.timestamp
      @value += other.value if other
    end

    def to_hash
      { timestamp: @timestamp, value: @value }
    end

    def to_json(*args)
      "{\"timestamp\":#{@timestamp},\"value\":#{@value}}"
    end

    def ==(other)
      @timestamp == other.timestamp && @value == other.value
    end
  end
end
