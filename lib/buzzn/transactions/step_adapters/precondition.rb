require_relative 'abstract'

module Transactions::StepAdapters
  class Precondition < Abstract

    def do_call(operation, options, **kwargs)
      schema = operation.()
      unless schema.is_a? Dry::Validation::Schema
        raise ArgumentError.new("step +#{options[:step_name]}+ needs operation which returns a Dry::Validation::Schema instance")
      end
      resource = kwargs[:resource]
      result = schema.call(resource.model)
      if result.success?
        Success(kwargs)
      else
        raise Buzzn::ValidationError.new(result.errors)
        # TODO better use this and handle on roda - see transactions/base
        #Failure(result.errors)
      end

    end

    register :precondition, Precondition.new

  end
end
