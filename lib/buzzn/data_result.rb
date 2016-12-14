module Buzzn
  class DataResult < DataPoint
    attr_reader :resource_id, :mode

    def self.from_json(data)
      from_hash(JSON.parse(data, symbolize_names: true))
    end

    def self.from_hash(data)
      new(data[:timestamp], data[:value],
          data[:resource_id], data[:mode])
    end

    def initialize(timestamp, value, resource_id, mode)
      super(timestamp, value)
      mode = (mode || '').to_sym
      raise "unkown mode '#{mode}'" unless [:in, :out].include?(mode)
      @mode = mode
      @resource_id = resource_id
    end

    def add(other)
      raise 'resource_id mismatch' if @resource_id != other.resource_id
      raise 'mode mismatch' if @mode != other.mode
      @value += other.value
    end
    alias :add_all :add

    def to_hash
      super.merge(resource_id: @resource_id, mode: @mode) 
    end
  end
end
