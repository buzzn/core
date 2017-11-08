require_relative '../authorization'

class Operations::Authorization::Delete
  include Dry::Transaction::Operation

  def call(input, resource = nil)
    raise ArgumentError.new('missing resource') unless resource

    if resource.deletable?
      Dry::Monads.Right(input)
    else
      raise Buzzn::PermissionDenied.new(resource, :delete, resource.current_user)
      # TODO better a Left Monad and handle on roda
    end
  end
end
