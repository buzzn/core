module Buzzn

  class DataPoint
    attr_reader :timestamp, :value

    def initialize(timestamp, value)
      @timestamp = timestamp
      @value = value
    end
  end

  class DataResult < DataPoint
    attr_reader :resource_id, :mode

    def initialize(resource_id, timestamp, value, mode)
      super(timestamp, value)
      @resource_id = resource_id
      @mode = mode
    end
  end

  class DataResultSet < Array
    attr_reader :resource_id

    def initialize(resource_id)
      @resource_id = resource_id
    end

    def add(timestamp, value)
      self.push(DataPoint.new(timestamp, value))
    end
  end
end
