class Transactions::StepAdapters < Dry::Transaction::StepAdapters
  extend Dry::Monads::Result::Mixin

  register :validate, -> operation, options, args {
    schema = operation.()
    unless schema.is_a? Dry::Validation::Schema
      raise ArgumentError.new("step +#{options[:step_name]}+ needs operation which returns a Dry::Validation::Schema instance")
    end
    kwargs = args[0]
#    unless kwargs[:params]
#      raise ArgumentError.new("step +#{options[:step_name]}+ requires input provided via +params:+")
    #    end
    # FIXME help with transition to more intiutive transaction setup
    params = kwargs[:params] || kwargs
    result = schema.call(params)
    if result.success?
     # FIXME help with transition to more intiutive transaction setup
      if kwargs.key?(:params)
        kwargs[:params] = result.output
        Success(kwargs)
      else
        Success(result.output)
      end
    else
      raise Buzzn::ValidationError.new(result.errors)
      # TODO better use this and handle on roda - see transactions/base
      #Failure(result.errors)
    end
  }

end
