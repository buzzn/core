require_relative '../authorization'

class Operations::Authorization::Update

  def call(resource:, **)
    unless resource.updatable?
      raise Buzzn::PermissionDenied.new(resource, :update,
                                        resource.security_context.current_user)
      # TODO better a Left Monad and handle on roda
    end
    true
  end

end
