require_relative '../authorization'

class Operations::Authorization::Generic
  include Dry::Transaction::Operation

  def call(input, resource, *allowed_roles)
    if resource.allowed?(allowed_roles)
      Dry::Monads.Right(input)
    else
      raise Buzzn::PermissionDenied.new(resource, nil, resource.current_user)
      # TODO better a Left Monad and handle on roda
    end
  end
end
