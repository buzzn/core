module Buzzn::Services

  class DataSourceRegistry
    include Import.args['service.redis']

    def initialize(redis = Redis.current, *sources)
      @logger = Buzzn::Logger.new(self)
      @container = Dry::Container.new
      sources.each do |source|
        add_source(source)
      end
      add_source(Buzzn::Discovergy::DataSource.new(redis))
      add_source(Buzzn::MissingDataSource.new)
      add_source(Buzzn::StandardProfile::DataSource.new)
      add_source(Buzzn::Virtual::DataSource.new(self))
    end

    def add_source(source)
      unless source.is_a?(Buzzn::DataSource)
        raise ArgumentError.new("is not a #{Buzzn::DataSource}: #{source.class}")
      end
      @container.register(source.class::NAME, source)
      @logger.info{"registered #{source.class::NAME}: #{source}"}
    end

    def get(data_source)
      @container[data_source]
    end

    def each(&block)
      @container.each_key do |key|
        block.call(@container[key])
      end
    end
  end
end
