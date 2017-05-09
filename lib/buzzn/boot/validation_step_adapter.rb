require 'dry-transaction'
module Buzzn
  module Boot
    class ValidationStepAdapter
      def call(step, *args, input)
        result = step.operation.call input
        if result.success?
          Dry::Monads.Right(result.output)
        else
          raise Buzzn::ValidationError.new(result.errors)
          # TODO better use this and handle on roda
          #Dry::Monads.Left(result.errors)
        end
      end
    end
    Dry::Transaction::StepAdapters.register :validate, ValidationStepAdapter.new
  end
end
