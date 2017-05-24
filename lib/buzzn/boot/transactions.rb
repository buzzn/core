require_relative 'validation_step_adapter'
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

      attr_reader :container, :steps

      def initialize
        @container = Dry::Container.new
        @steps = Dry::Container.new
      end

      def define(name, &block)
        container.register(name, Dry.Transaction(container: steps, &block))
      rescue => e
        # just print out the error as db:init does autoload those files
        # in the second run or so
        warn e.message
      end

      def register_validation(name, &block)
        steps.register(name, Dry::Validation.Form(Validation::Form, &block))
      rescue => e
        # just print out the error as db:init does autoload those files
        # in the second run or so
        warn e.message
      end

      def register_step(name, operation = nil, &block)
        if operation
          steps.register(name, operation)
        else
          steps.register(name, block)
        end
      rescue => e
        # just print out the error as db:init does autoload those files
        # in the second run or so
        warn e.message
      end
    end
  end
end
