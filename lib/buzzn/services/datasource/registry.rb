require_relative '../datasource'

class Services::Datasource::Registry

  def initialize
    @logger = Buzzn::Logger.new(self)
    @container = Dry::Container.new
  end

  def add_source(source)
    @container.register(source.class::NAME, source)
    @logger.debug{"registered #{source.class::NAME}: #{source}"}
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
