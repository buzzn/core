module Buzzn
  class DataResult < DataPoint
    attr_reader :resource_id, :mode, :expires_at

    def self.from_json(json)
      return unless json
      from_hash(JSON.parse(json, symbolize_names: true), json)
    end

    def self.from_hash(data, json = nil)
      new(data[:timestamp], data[:value],
          data[:resource_id], data[:mode],
          data[:expires_at], json)
    end

    def initialize(timestamp, value, resource_id, mode, expires_at = nil, json =nil)
      super(timestamp, value)
      mode = (mode || '').to_sym
      raise "unkown mode '#{mode}'" unless [:in, :out].include?(mode)
      @mode = mode
      @resource_id = resource_id
      @expires_at = expires_at.to_f
      freeze if @json = json
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

    def freeze
      @json = to_json
      super
    end

    def to_json(*args)
      @json || '{"timestamp":' << @timestamp.to_s << ',"value":' << @value.to_s << ',"resource_id":"' << @resource_id << '","mode":"' << @mode.to_s << '","expires_at":' << expires_at.to_s << '}'
    end
  end
end
