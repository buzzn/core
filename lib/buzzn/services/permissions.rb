module Buzzn::Services
  class Permissions
    include Dry::Container::Mixin

    setting :path, 'lib/buzzn/permissions'

    class Resolver < Dry::Container::Resolver
      def initialize(config)
        @config = config
      end

      def call(container, key)
        unless container.key?(key)
          file = key.to_s.underscore.sub('resource', 'permission') + '.rb'
          require File.join('.', @config.path, file)
        end
        super(container, key)
      rescue LoadError
        warn "missing permission for #{key}"
        call(container, :no_permission) unless key == :no_permission
      end
    end
    
    configure do |config|
      config.resolver = Resolver.new(config)
    end
  end
end
