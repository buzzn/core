require_relative 'abstract'

module Transactions::StepAdapters
  class Add < Abstract

    def do_call(operation, options, **kwargs)
      Success(kwargs.merge(options[:step_name] => operation.(**kwargs)))
    end

    register :add, Add.new

  end
end
