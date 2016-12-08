module Buzzn

  class CurrentPower

    def initialize(data_source_registry)
      @registry = data_source_registry
    end

    def for_register(register, interval)
      check(interval)
      mode = register.is_a?(Register::Input)? :in : :out
      @registry.get(register.data_source).aggregated(register, interval, mode)
    end

    def for_group(group, interval)
      check(interval)
      result = []
      @registry.each do |key, data_source|
        [:in, :out].each do |mode|
          result += data_source.collection(group, interval, mode)
        end
      end
      result
    end

    def for_group_aggregated(group, interval)
      check(interval)
      sum_in, sum_out = 0, 0
      @registry.each do |key, data_source|
          sum_in += data_source.aggregated(group, interval, :in).value
          sum_out += data_source.aggregated(group, interval, :out).value
        end
      end
    [ Buzzn::DataResult.new(group.id, now = Time.current, sum_in, :in),
       Buzzn::DataResult.new(group.id, now = Time.current, sum_out, :out) ]
    end

  private

    def check(interval)
      if !interval.live?
        raise Buzzn::DataSourceError.new('ERROR - you requested collected data with wrong resolution')
      end
    end
  end
end
