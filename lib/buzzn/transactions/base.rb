require_relative '../transactions'
require_relative 'step_adapters'

class Transactions::Base

  include Dry::Transaction(container: Buzzn::Boot::MainContainer, step_adapters: Transactions::StepAdapters)

  class << self

    def nnew(**)
      if ['call', 'for', 'with_step_args'].include? caller_locations[0].label
        super
      else
        raise NoMethodError.new("#{caller_locations[0]}: semi private method 'new' called for #{self}")
      end
    end

    def call(*args)
      new.call(*args)
    end

    def for(subject = nil, *steps)
      args = {}
      if subject
        arg = [subject]
        steps.each { |s| args[s] = arg }
      end
      new.with_step_args(args)
    end

  end

  def db_transaction(input)
    result = nil
    ActiveRecord::Base.transaction(requires_new: true) do
      result = yield(Success(input))
      return result if result.is_a?(Dry::Monads::Result::Failure)
      unless result.value.invariant.success?
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
