module Buzzn
  class InOutDataResults

    attr_reader :timestamp, :in, :out, :resource_id

    def self.from_json(data)
      from_hash(JSON.parse(data, symbolize_names: true))
    end

    def self.from_hash(data)
      new(data[:timestamp], data[:in], data[:out], data[:resource_id])
    end

    def initialize(timestamp, input, output, resource_id)
      @timestamp = case timestamp
                   when Time
                     timestamp.to_f
                   when String
                     timestamp.to_f
                   when Integer
                     timestamp / 1000.0
                   when Float
                     timestamp
                   else
                     raise ArgumentError.new("timestamp not a Time or String or Fixnum or Float: #{timestamp.class}")
                   end
      @in = input.to_f
      @out = output.to_f
      @resource_id = resource_id
    end

    def to_hash
      { timestamp: @timestamp, in: @in, out: @out, resource_id: @resource_id }
    end

  end
end
