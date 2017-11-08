require_relative '../authorization'

class Operations::Authorization::Generic
  include Dry::Transaction::Operation

  def call(input, resource = nil, *allowed_roles)
    raise ArgumentError.new('missing resource') unless resource

    if resource.allowed?(allowed_roles)
      Dry::Monads.Right(input)
    else
      raise Buzzn::PermissionDenied.new(resource, key, resource.current_user)
      # TODO better a Left Monad and handle on roda
    end
  end
end
