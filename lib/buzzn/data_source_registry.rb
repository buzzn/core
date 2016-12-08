module Buzzn

  class DataSourceRegistry

    def initialize(map = {})
      @registry = map.dup
      @registry[:discovergy] ||= Buzzn::Discovergy::DataSource.new,
      @registry[:mysmartgrid] ||= Buzzn::Mysmartgrid::DataSource.new
    end

    def get(data_source)
      @registry[data_source]
    end

    def each(&block)
      @registry.each do |key, data_source|
        block.call(key, data_source)
      end
    end
  end
end
