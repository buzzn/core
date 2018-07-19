require_relative '../authorization'

# checks whether a document can be created of the resource
class Operations::Authorization::Document

  def call(resource:, **)
    unless resource.documentable?
      raise Buzzn::PermissionDenied.new(resource, :document, resource.security_context.current_user)
      # TODO better a Left Monad and handle on roda
    end
    true
  end

end
