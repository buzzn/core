require_relative '../authorization'

class Operations::Authorization::Create
  include Dry::Transaction::Operation

  def call(input, resources = nil)
    raise ArgumentError.new('missing resources') unless resources

    if resources.createable?
      Dry::Monads.Right(input)
    else
      raise Buzzn::PermissionDenied.new(resources.instance_class, :create, resources.current_user)
      # TODO better a Left Monad and handle on roda
    end
  end
end
