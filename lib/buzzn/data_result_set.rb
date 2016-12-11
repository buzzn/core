module Buzzn
  class DataResultSet
    attr_reader :resource_id, :in, :out, :units

    class << self
      private :new

      def from_json(data)
        from_hash(JSON.parse(data, symbolize_names: true))
      end

      def from_hash(data)
        input = data[:in].collect { |i| DataPoint.from_hash(i) }
        output = data[:out].collect { |i| DataPoint.from_hash(i) }
        new(data[:units], data[:resource_id], input, output)
      end

      def milliwatt(*args)
        new(*([:milliwatt] + args))
      end

      def milliwatt_hour(*args)
        new(*([:milliwatt_hour] + args))
      end

    end

    def initialize(units, resource_id, input = [], output = [])
      @units = units.to_sym
      @resource_id = resource_id
      @in = input
      @out = output
    end

    def add(timestamp, value, mode)
      array = mode == :in ? @in : @out
      array.push(DataPoint.new(timestamp, value))
    end

    def add_all(set)
      raise ArgumentError.new('mismatch units') if @units != set.units
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

    def units(units)
      unless [:milliwatt, :milliwatt_hour].include?(units)
        raise ArgumentError.new('only :milliwatt and :milliwatt_hour allowed')
      end
      @units = units
      freeze
    end

    def freeze
      @in.freeze
      @out.freeze
    end

    def to_hash
      { units: @units,
        resource_id: @resource_id,
        in: @in.collect { |i| i.to_hash },
        out: @out.collect { |i| i.to_hash } }
    end
  end
end
