require 'buzzn'

module Buzzn
  class DataResult < Array
    attr_reader :resource_id

    def initialize(resource_id)
      @resource_id = resource_id
    end

    class DataPoint
      attr_reader :timestamp, :value

      def initialize(timestamp, value)
        @timestamp = timestamp
        @value = value
      end
    end

    def add(timestamp, value)
      self.push(DataPoint.new(timestamp, value))
    end
  end
end
