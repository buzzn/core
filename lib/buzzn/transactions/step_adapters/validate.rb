require_relative 'abstract'

module Transactions::StepAdapters
  class Validate < Abstract

    def do_call(operation, options, params:, **kwargs)
      schema = operation.(**kwargs)
      unless schema.is_a? Dry::Validation::Schema
        raise ArgumentError.new("step +#{options[:step_name]}+ needs operation which returns a Dry::Validation::Schema instance")
      end
      result = schema.call(params)
      if result.success?
        Success(kwargs.merge(params: result.output))
      else
        raise Buzzn::ValidationError.new(result.errors)
        # TODO better use this and handle on roda - see transactions/base
        #Failure(result.errors)
      end
    end

    register :validate, Validate.new

  end
end
