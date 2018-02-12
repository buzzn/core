require 'dry-container'
require_relative 'transactions'

module Buzzn
  module Boot
    class MainContainer

      extend Dry::Container::Mixin

      def self.register_config(key, value)
        register("config.#{key}", value)
      end

      def self.key?(key)
        if k = env_key(key)
          ENV.key?(k)
        else
          super
        end
      end

      private

      def self.env_key(key)
        if key.to_s.start_with?('config.')
          key.to_s[7..-1].upcase
        end
      end

      class Resolver < Dry::Container::Resolver

        def call(container, key)
          if k = MainContainer.env_key(key)
            get_env(k) || super
          else
            super
          end
        end

        private

        def get_env(key)
          ENV[key]
        end

      end

      configure do|config|
        config.resolver = Resolver.new
      end

    end
  end
end
