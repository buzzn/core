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
      if other && !other.empty?
        other.each { |i| push(i) }
        @expires_at = [@expires_at.to_f, other.expires_at.to_f].max
      end
      self
    end

    def to_hash
      { array: collect {|i| i.to_hash }, expires_at: @expires_at }
    end

    def to_json(*args)
      @json || "{\"expires_at\":#{expires_at},\"array\":#{super}}"
    end

    def inspect
      "#<#{self.class}\:#{object_id.to_s(16)} @expires_at: #{@expires_at}, #{super.inspect}>"
    end
    alias :to_s :inspect
  end
end
