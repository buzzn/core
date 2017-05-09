require 'dry-container'

module Buzzn
  module Services

    class MainContainer
      extend Dry::Container::Mixin

      class Resolver < Dry::Container::Resolver
        def call(container, key)
          if key.to_s.starts_with?('config')
            get_rails_config(key.to_s[7..-1])
          elsif key.to_s.starts_with?('secrets')
            get_rails_secrets(key.to_s[8..-1])
          else
            super
          end
        end

        private

        # glue code to bridge rails config used by services
        def get_rails_config(key)
          get_rails_stuff(key, 'config', 'x')
        end

        # glue code to bridge rails secrets used by services
        def get_rails_secrets(key)
          get_rails_stuff(key, 'secrets')
        end

        def get_rails_stuff(key, *methods)
          result = Buzzn::Application
          methods.each do |m|
            result = result.send(m)
          end
          result = result.send(key)
          if result.is_a?(Hash) && result.empty?
            raise Dry::Container::Error, "Nothing found in Buzzn::Application.#{methods.join('.')} for #{key.inspect}"
          else
            result
          end
        end
          
      end

      configure do|config|
        config.resolver = Resolver.new        
      end
    end
  end
end
