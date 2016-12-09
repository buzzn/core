module Buzzn
  class DataResult < DataPoint
    attr_reader :resource_id, :mode

    def initialize(resource_id, timestamp, value, mode)
      super(timestamp, value)
      @mode = mode
      @resource_id = resource_id
    end

    def to_hash
      super.merge(resource_id: @resource_id, mode: @mode) 
    end
  end
end
