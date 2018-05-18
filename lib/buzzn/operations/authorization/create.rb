require_relative '../authorization'

class Operations::Authorization::Create

  def call(resource:, **)
    unless resource.createable?
      raise Buzzn::PermissionDenied.new(resource.instance_class, :create, resource.security_context.current_user)
      # TODO better a Left Monad and handle on roda
    end
    true
  end

end
