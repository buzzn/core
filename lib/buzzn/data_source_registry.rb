module Buzzn

  class DataSourceRegistry

    def initialize(redis = Redis.current, *sources)
      @registry = {}
      sources.each do |source|
        add(source)
      end
      @registry[Buzzn::Discovergy::DataSource::NAME] ||= Buzzn::Discovergy::DataSource.new(redis)
      @registry[Buzzn::MissingDataSource::NAME] ||= Buzzn::MissingDataSource.new
      #@registry[Buzzn::Mysmartgrid::DataSource::NAME] ||= Buzzn::Mysmartgrid::DataSource.new(redis)
      @registry[Buzzn::StandardProfile::DataSource::NAME] ||= Buzzn::StandardProfile::DataSource.new

      @registry.each do |key, data_source|
        raise "datasource for :#{key} is not a #{Buzzn::DataSource}: #{data_source.class}" unless data_source.is_a?(Buzzn::DataSource)
      end
    end

    def add(source)
      @registry[source.class.const_get(:NAME)] = source
    end

    def get(data_source)
      data_source = data_source.to_sym if data_source
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
