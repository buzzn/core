require_relative 'abstract'
require_relative '../../schemas/support/enable_dry_validation'

module Transactions::StepAdapters
  class Precondition < Abstract

    def do_call(operation, options, resource:, **kwargs)
      schema = operation.()
      unless schema.is_a? Dry::Validation::Schema
        raise ArgumentError.new("step +#{options[:step_name]}+ needs operation which returns a Dry::Validation::Schema instance")
      end
      subject = Schemas::Support::ActiveRecordValidator.new(resource.object)
      result = schema.call(subject)
      if result.success?
        Success(kwargs.merge(resource: resource))
      else
        raise Buzzn::ValidationError.new(result.errors)
        # TODO better use this and handle on roda - see transactions/base
        #Failure(result.errors)
      end
    end

    register :precondition, Precondition.new

  end
end
