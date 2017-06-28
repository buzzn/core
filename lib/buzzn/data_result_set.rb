module Buzzn
  class DataResultSet
    attr_reader :resource_id, :in, :out, :units
    attr_accessor :expires_at

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
      array =
        case mode
        when 'in'
          @in
        when 'out'
          @out
        else
          raise "unknown mode #{mode.inspect}"
        end
      array.push(Buzzn::DataPoint.new(timestamp, value))
    end

    def add_all(set, duration)
      return unless set
      raise ArgumentError.new('mismatch units') if @units != set.units
      _add(@in, set.in, duration)
      _add(@out, set.out, duration)
    end

    def _add(target, source, duration)
      if target.empty?
        target.replace(source.dup)
      elsif source.empty?
        return
      else
        merge_lists(target, source, duration, '+')
      end
    end
    private :_add

    def subtract_all(set, duration)
      return unless set
      raise ArgumentError.new('mismatch units') if @units != set.units
      _subtract(@in, set.in, duration)
      _subtract(@out, set.out, duration)
    end

    def _subtract(target, source, duration)
      if target.empty?
        target.replace(source.dup)
        _multiply_by_minus_one(target)
      elsif source.empty?
        return
      else
        merge_lists(target, source, duration, '-')
      end
    end
    private :_subtract

    def _multiply_by_minus_one(set)
      set.each do |data_point|
        data_point.value > 0 ? data_point.subtract_value(2 * data_point.value) : data_point.add_value(2 * data_point.value.abs)
      end
    end
    private :_multiply_by_minus_one

    # this method returns the data combined in either the @in array or the @out array
    # need for virtual registers
    def combine(direction, duration)
      case direction
      when 'in'
        _add(@in, @out, duration)
        @out.replace([])
      when 'out'
        _add(@out, @in, duration)
        @in.replace([])
      else
        raise "unknown direction #{direction.inspect}"
      end
    end

    def freeze
      @json = to_json
      super
      @in.freeze
      @out.freeze
      self
    end

    def to_hash
      { units: @units,
        resource_id: @resource_id,
        in: @in.collect { |i| i.to_hash },
        out: @out.collect { |i| i.to_hash } }
    end

    def to_json(*args)
      @json || '{"units":"' << @units.to_s << '","resource_id":"' << @resource_id << '","in":' << @in.to_json << ',"out":' << @out.to_json << '}'
    end

    def merge_lists(target, source, duration, operator)
      for i in 0...source.size
        if source[i]
          key = source[i].timestamp
          value = source[i].value
          timestamp_index = find_matching_timestamp(key, target, duration)
          if timestamp_index == -1
            if operator == '+'
              target.push(source[i])
            else
              target.push(Buzzn::DataPoint.new(key, -1 * value))
            end
          else
            if operator == '+'
              target[timestamp_index].add_value(value)
            else
              target[timestamp_index].subtract_value(value)
            end
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
    private :find_matching_timestamp

    def last_timestamp
      (@in.collect { |i| i.timestamp } +
         @out.collect { |i| i.timestamp }).max || 0
    end
  end
end
