module Buzzn
  class DataResultSet
    attr_reader :resource_id, :in, :out, :units

    class << self
      private :new

      def from_json(data)
        from_hash(JSON.parse(data, symbolize_names: true))
      end

      def from_hash(data)
        input = data[:in].collect { |i| Buzzn::DataPoint.from_hash(i) }
        output = data[:out].collect { |i| Buzzn::DataPoint.from_hash(i) }
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

    def add_all(set, duration)
      return unless set
      raise ArgumentError.new('mismatch units') if @units != set.units
      _add(@in, set.in, duration)
      _add(@out, set.out, duration)
    end

    def _add(target, source, duration)
      if target.empty?
        target = source
      elsif source.empty?
        return
      else
        sum_lists(target, source, duration)
      end
    end
    private :_add

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

    def sum_lists(target, source, duration)
      for i in 0...source.size
        if source[i]
          key = source[i].timestamp
          value = source[i].value
          timestamp_index = find_matching_timestamp(key, target, duration)
          if timestamp_index == -1
            target.push(DataPoint.new(key, value))
          else
            target[timestamp_index].add(DataPoint.new(target[timestamp_index].timestamp, value))
          end
        end
      end
      return target.sort! {|a, b| a.timestamp <=> b.timestamp}
    end

    def find_matching_timestamp(key, arr, duration)
      for i in 0...arr.size
        case duration
        when :year
          if (key - arr[i].timestamp).abs < 1339200 # half a month
            return i
          end
        when :month
          if (key - arr[i].timestamp).abs < 43200 # half a day
            return i
          end
        when :day #15 minutes
          if (key - arr[i].timestamp).abs < 450 # half a quarter hour
            return i
          end
        else # hour or present
          if (key - arr[i].timestamp).abs < 2 # 2 seconds
            return i
          end
        end
      end
      return -1
    end
  end
end
