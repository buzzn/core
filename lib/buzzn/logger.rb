module Buzzn
  class Logger

    def self.root=(root)
      @root = root
      @loggers ||= {}
      @loggers.each do |k, logger|
        logger.instance_variable_set('@root', root)
      end
    end

    def self.root
      Logger.new(Buzzn)
    end

    def self.new(clazz, root = nil)
      raise 'set root logger first' unless @loggers
      clazz = clazz.class unless clazz.is_a? Class
      @loggers[clazz] ||= super(clazz, @root)
    end

    def initialize(clazz, root)
      @category = Dry::Core::Inflector.underscore(clazz.to_s).gsub('/', '.')
      @root = root
    end

    def debug?
      @root.debug? rescue false
    end

    [:debug, :info, :warn, :error].each do |method|
      define_method method do |msg = nil, &block|
        @root.send method do
          "#{Time.current.strftime('%Y-%m-%d %H:%M:%S')} #{method.upcase} [#{@category}] <#{Thread.current.object_id.to_s(16)}> #{msg || block.call}"
        end
      end
    end

    def <<(msg)
      @root.<< msg if @root.info? rescue nil
    end

  end
end
