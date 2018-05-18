require_relative '../authorization'

class Operations::Authorization::Delete

  def call(resource:)
    unless resource.deletable?
      raise Buzzn::PermissionDenied.new(resource, :delete,
                                        resource.security_context.current_user)
      # TODO better a Left Monad and handle on roda
    end
    true
  end

end
