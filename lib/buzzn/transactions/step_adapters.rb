class Transactions::StepAdapters < Dry::Transaction::StepAdapters

  extend Dry::Monads::Result::Mixin

  register :add, ->(operation, options, args) {
    kwargs = args[0]
    Success(kwargs.merge(operation.(**kwargs)))
  }

  register :authorize, ->(operation, options, args) {
    kwargs = args[0]
    resource = kwargs[:resource]
    security = resource.security_context
    allowed_roles = *operation.(permission_context: security.permissions)
    unless resource.allowed?(allowed_roles)
      raise Buzzn::PermissionDenied.new(resource, nil, security.current_user)
      # TODO better a Left Monad and handle on roda
    end
    Success(kwargs)
  }

  register :validate, ->(operation, options, args) {
    schema = operation.()
    unless schema.is_a? Dry::Validation::Schema
      raise ArgumentError.new("step +#{options[:step_name]}+ needs operation which returns a Dry::Validation::Schema instance")
    end
    kwargs = args[0]
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

  register :precondition, ->(operation, options, args) {
    schema = operation.()
    unless schema.is_a? Dry::Validation::Schema
      raise ArgumentError.new("step +#{options[:step_name]}+ needs operation which returns a Dry::Validation::Schema instance")
    end
    kwargs = args[0]
    resource = kwargs[:resource]
    result = schema.call(resource.model)
    if result.success?
      Success(kwargs)
    else
      raise Buzzn::ValidationError.new(result.errors)
      # TODO better use this and handle on roda - see transactions/base
      #Failure(result.errors)
    end
  }

end
