require_relative '../authorization'

class Operations::Authorization::Update
  include Dry::Transaction::Operation

  def call(input, resource)
    if resource.updatable?
      Dry::Monads.Right(input)
    else
      raise Buzzn::PermissionDenied.new(resource, :update, resource.current_user)
      # TODO better a Left Monad and handle on roda
    end
  end
end
