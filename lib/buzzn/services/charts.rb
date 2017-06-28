module Buzzn::Services

  class Charts
    include Import.args[registry: 'service.data_source_registry']

    def for_register(register, interval)
      register = register.object if register.respond_to? :object
      raise ArgumentError.new("not a #{Register::Base}") unless register.is_a?(Register::Base)
      raise ArgumentError.new("not a #{Buzzn::Interval}") unless interval.is_a?(Buzzn::Interval)
      result = @registry.get(register.data_source).aggregated(register, register.direction, interval)
      finalize(result, interval)
    end

    def finalize(result, interval)
      ttl = if interval.to < Time.current.to_f
              1.day
            else
              case interval.duration
              when :second
                15.seconds
              when :hour
                15.seconds
              when :day
                15.minutes
              when :month
                1.hour
              when :year
                1.day
              end
            end
      result.expires_at = Time.current.to_f + ttl
      result.freeze
    end

    def for_group(group, interval)
      group = group.object if group.respond_to? :object
      raise ArgumentError.new("not a #{Group::Base}") unless group.is_a?(Group::Base)
      raise ArgumentError.new("not a #{Buzzn::Interval}") unless interval.is_a?(Buzzn::Interval)
      units = interval.hour? || interval.day? ? :milliwatt : :milliwatt_hour
      result = Buzzn::DataResultSet.send(units, group.id)
      @registry.each do |data_source|
        result.add_all(data_source.aggregated(group, 'in', interval), interval.duration)
        result.add_all(data_source.aggregated(group, 'out', interval), interval.duration)
      end
      finalize(result, interval)
    end

  end
end
