require_relative 'abstract'

module Transactions::StepAdapters
  class Validate < Abstract

    def do_call(operation, options, **kwargs)
      schema = operation.()
      unless schema.is_a? Dry::Validation::Schema
        raise ArgumentError.new("step +#{options[:step_name]}+ needs operation which returns a Dry::Validation::Schema instance")
      end
      params = kwargs[:params]
      result = schema.call(params)
      if result.success?
        kwargs[:params] = result.output
        Success(kwargs)
      else
        raise Buzzn::ValidationError.new(result.errors)
        # TODO better use this and handle on roda - see transactions/base
        #Failure(result.errors)
      end
    end

    register :validate, Validate.new

  end
end
