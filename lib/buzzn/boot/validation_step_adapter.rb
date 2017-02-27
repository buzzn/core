require 'dry-transaction'
module Buzzn
  module Boot
    class ValidationStepAdapter
      def call(step, *args, input)
        result = step.operation.call input
        if result.success?
          Dry::Monads.Right(result.output)
        else
          Dry::Monads.Left(Buzzn::ValidationError.new(result.errors))
        end
      end
    end
    Dry::Transaction::StepAdapters.register :validate, ValidationStepAdapter.new
  end
end
