require_relative '../transactions'
require_relative 'step_adapters'

class Transactions::Base

  include Dry::Transaction(container: Buzzn::Boot::MainContainer, step_adapters: Transactions::StepAdapters::Registry)

  class << self

    def call(*args)
      new.call(*args)
    end

  end

  def db_transaction(input)
    result = nil
    ActiveRecord::Base.transaction(requires_new: true) do
      result = yield(Success(input))
      return result if result.is_a?(Dry::Monads::Result::Failure)
      if result.value.invariant&.failure?
        raise ActiveRecord::Rollback
      end
    end
    if result.value.persisted?
      result
    else
      raise Buzzn::ValidationError.new(result.value.invariant.errors)
      # TODO better use this and handle on roda - see operations/validation
      #Failure(entity.invariant.errors)
    end
  end

end
