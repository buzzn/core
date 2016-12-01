require 'buzzn'

module Buzzn
  class CrawlerResult < Array
    attr_reader :external_id

    def initialize(external_id)
      @external_id = external_id
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