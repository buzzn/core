require 'dry-container'
require_relative 'transactions'

module Buzzn
  module Boot

    class MainContainer
      extend Dry::Container::Mixin

      def self.register_config(key, value)
        register("config.#{key}", value)
      end

      class Resolver < Dry::Container::Resolver
        def call(container, key)
          if key.to_s.start_with?('config.')
            get_env(key.to_s[7..-1]) || super
#          elsif key.to_s.start_with?('transaction.')
 #           Buzzn::Transaction.transactions.container[key.to_s[12..-1]]
  #        elsif key.to_s.start_with?('schema.')
   #         Buzzn::Transaction.transactions.steps["#{key.to_s[7..-1]}_schema"]
          else
            super
          end
        end

        private

        def get_env(key)
          ENV[key.upcase]
        end

      end

      configure do|config|
        config.resolver = Resolver.new
      end
    end
  end
end
