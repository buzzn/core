require_relative '../authorization'

class Operations::Authorization::Create

  include Dry::Transaction::Operation

  def call(input, resources)
    if resources.createable?
      Success(input)
    else
      raise Buzzn::PermissionDenied.new(resources.instance_class, :create, resources.security_context.current_user)
      # TODO better a Left Monad and handle on roda
    end
  end

end
