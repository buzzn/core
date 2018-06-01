require_relative 'abstract'

module Transactions::StepAdapters
  class Authorize < Abstract

    def do_call(operation, options, **kwargs)
      resource = kwargs[:resource]
      security = resource.security_context
      allowed_roles = operation.(permission_context: security.permissions)
      unless resource.allowed?(allowed_roles)
        action = options[:step_name]
        raise Buzzn::PermissionDenied.new(resource, action, security.current_user)
        # TODO better a Left Monad and handle on roda
      end
      Success(kwargs)
    end

    register :authorize, Authorize.new

  end
end
