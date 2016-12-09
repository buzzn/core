module Buzzn
  class DataResults
    attr_reader :resource_id, :in, :out

    def initialize(resource_id, timestamp, input, output)
      @in = input
      @out = output
      @timestamp = timestamp
      @resource_id = resource_id
    end

    def to_hash
      { resource_id: @resource_id, timestamp: @timestamp, in: @in, out: @out }
    end
  end
end
