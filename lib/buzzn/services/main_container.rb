require 'dry-container'

module Buzzn
  module Services

    class MainContainer
      extend Dry::Container::Mixin

      class Resolver < Dry::Container::Resolver
        def call(container, key)
          if key.to_s.starts_with?('config')
            get_rails_config(key.to_s[7..-1])
          else
            super
          end
        end

        # glue code to bridge rails config used by services
        def get_rails_config(key)
          result = Buzzn::Application.config.x.send key
          if result.is_a?(Hash) && result.empty?
            raise Dry::Container::Error, "Nothing found in Buzzn::Application.config.x for #{key.inspect}"
          else
            result
          end
        end
      end

      configure do|config|
        config.resolver = Resolver.new        
      end
    
      #register('config.templates.path', nil)
    end
  end
end
