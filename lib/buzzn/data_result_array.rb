module Buzzn
  class DataResultArray < Array
    attr_reader :expires_at

    def self.from_json(json)
      return unless json
      from_hash(JSON.parse(json, symbolize_names: true), json)
    end

    def self.from_hash(data, json = nil)
      result = new(data[:expires_at], json)
      (data[:array] || []).collect do |i|
        result << DataResult.from_hash(i)
      end
      result.freeze if json
      result
    end

    def initialize(expires_at = nil, json = nil)
      super()
      @expires_at = expires_at
      @json = json
    end

    def +(other)
      other.each { |i| push(i) }
      self
    end

    def to_hash
      { array: collect {|i| i.to_hash }, expires_at: @expires_at }
    end

    def to_json(*args)
      @json || "{\"expires_at\":#{expires_at},\"array\":#{super}}"
    end
  end
end
