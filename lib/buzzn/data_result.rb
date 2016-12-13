module Buzzn
  class DataResult < DataPoint
    attr_reader :resource_id, :mode

    def self.from_hash(data)
      new(data[:resource_id], Time.parse(data[:timestamp]),
          data[:value], data[:mode].to_sym)
    end

    def initialize(resource_id, timestamp, value, mode)
      super(timestamp, value)
      raise "unkown mode '#{mode}'" unless [:in, :out].include?(mode)
      @mode = mode
      @resource_id = resource_id
    end

    def to_hash
      super.merge(resource_id: @resource_id, mode: @mode) 
    end
  end
end
