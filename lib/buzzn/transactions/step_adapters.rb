module Transactions::StepAdapters

  class Registry < Dry::Transaction::StepAdapters
  end

end

require_relative 'step_adapters/add'
require_relative 'step_adapters/authorize'
require_relative 'step_adapters/precondition'
require_relative 'step_adapters/validate'
