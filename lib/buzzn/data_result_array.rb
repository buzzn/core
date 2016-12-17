module Buzzn
  class DataResultArray < Array
    attr_reader :expires_at

    def self.from_json(data)
      from_hash(JSON.parse(data, symbolize_names: true))
    end

    def self.from_hash(data)
      result = new(data[:expires_at])
      data[:array].collect do |i|
        result << DataResult.from_hash(i)
      end
      result
    end

    def initialize(expires_at = nil)
      super()
      @expires_at = expires_at
    end

    def +(other)
      other.each { |i| push(i) }
      self
    end

    def to_hash
      { array: self, expires_at: @expires_at } 
    end
  end
end
