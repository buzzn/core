require_relative '../authorization'

class Operations::Authorization::Delete
  include Dry::Transaction::Operation

  def call(resource)
    if resource.deletable?
      Dry::Monads.Right(resource)
    else
      raise Buzzn::PermissionDenied.new(resource, :delete, resource.current_user)
      # TODO better a Left Monad and handle on roda
    end
  end
end
