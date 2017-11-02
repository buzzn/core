require_relative 'validation_step_adapter'
require_relative '../schemas/support/form'
module Buzzn
  class Transaction

    def self.transactions
      @transactions ||= Boot::Transactions.new
    end

    def self.define(&block)
      yield(transactions)
    end

  end

  module Boot
    class Transactions

      class Resolver < Dry::Container::Resolver
        def call(container, key)
          if key.respond_to?(:call)
            key
          else
            super
          end
        end
      end

      attr_reader :container, :steps

      def initialize
        @logger = Logger.new(self)
        @container = Dry::Container.new
        @steps = Dry::Container.new
        @steps.config.resolver = Resolver.new
      end

      def define(name, &block)
        container.register(name, Dry.Transaction(container: steps, &block))
        @logger.debug { "defined transaction #{name}" }
      end

      def register_validation(name, &block)
        steps.register(name, Dry::Validation.Form(Schemas::Form, &block))
        @logger.debug { "registered validation #{name}" }
      end

      def register_step(name, operation = nil, &block)
        if operation
          steps.register(name, operation)
        else
          steps.register(name, block)
        end
        @logger.debug { "registered step #{name}" }
      end
    end
  end
end
