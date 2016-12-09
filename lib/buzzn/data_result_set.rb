module Buzzn
  class DataResultSet
    attr_reader :resource_id, :in, :out

    def initialize(resource_id)
      @resource_id = resource_id
      @in = []
      @out = []
    end

    def add(timestamp, value, mode)
      array = mode == :in ? @in : @out
      array.push(DataPoint.new(timestamp, value))
    end

    def add_all(set)
      _add(@in, set.in)
      _add(@out, set.out)
    end

    def _add(target, source)
      source.each_with_index do |item, i|
        if old = target[i]
          old.add(item)
        else
          target[i] = item
        end
      end
    end
    private :_add

    def freeze
      @in.freeze
      @out.freeze
    end

    def to_hash
      { resource_id: @resource_id,
        in: @in.collect { |i| i.to_hash },
        out: @out.collect { |i| i.to_hash } }
    end
  end
end
