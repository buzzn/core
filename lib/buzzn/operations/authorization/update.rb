require_relative '../authorization'

class Operations::Authorization::Update

  include Dry::Transaction::Operation

  def call(resource:, **)
    unless resource.updatable?
      raise Buzzn::PermissionDenied.new(resource, :update, resource.current_user)
      # TODO better a Left Monad and handle on roda
    end
    true
  end

end
