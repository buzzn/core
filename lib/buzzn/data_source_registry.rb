module Buzzn

  class DataSourceRegistry

    def initialize(map = {})
      @registry = map.dup
      @registry[:discovergy] ||= Buzzn::Discovergy::DataSource.new
      #@registry[:mysmartgrid] ||= Buzzn::Mysmartgrid::DataSource.new
      #@registry[:standard_profile] ||= Buzzn::StandardProfile::DataSource.new
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
