module Buzzn

  class DataSourceRegistry

    def initialize(redis = Redis.current, map = {})
      @registry = map.dup
      @registry[:discovergy] ||= Buzzn::Discovergy::DataSource.new(redis)
      #@registry[:mysmartgrid] ||= Buzzn::Mysmartgrid::DataSource.new
      #@registry[:standard_profile] ||= Buzzn::StandardProfile::DataSource.new

      @registry.each do |key, data_source|
        raise "datasource for :#{key} is not a #{Buzzn::DataSource}: #{data_source.class}" unless data_source.is_a?(Buzzn::DataSource)
      end
    end

    def get(data_source)
      data_source = data_source.to_sym
      raise ArgumentError.new("can not handle #{data_source}") unless @registry.key?(data_source)
      @registry[data_source]
    end

    def each(&block)
      @registry.each do |key, data_source|
        block.call(key, data_source)
      end
    end
  end
end
