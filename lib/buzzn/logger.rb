module Buzzn
  class Logger
    def self.root=(root)
      @root = root
      @loggers = {}
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
      @category = clazz.to_s.underscore.sub('/', '.')
      @root = root
    end

    [:debug, :info, :warn, :error].each do |method|
      define_method method do |&block|
        @root.send method do
          "#{method.upcase} [#{@category}] <#{Thread.current.object_id.to_s(16)}> #{block.call}"
        end
      end
    end
  end
end
