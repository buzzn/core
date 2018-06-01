require_relative '../step_adapters'

class Transactions::StepAdapters::Abstract

  include Dry::Monads::Result::Mixin

  def self.register(*args)
    Transactions::StepAdapters::Registry.register(*args)
  end

  def call(operation, options, args)
    do_call(operation, options, **(args[0] || {}))
  end

end
