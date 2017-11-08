require_relative '../authorization'

class Operations::Action::Update
  include Dry::Transaction::Operation

  def call(input, resource = nil)
    raise ArgumentError.new('missing resource') unless resource

    # we deliver only millis to client and have to nil the nanos
    if (resource.object.updated_at.to_f * 1000).to_i != (input.delete(:updated_at).to_f * 1000).to_i
      # TODO better a Left Monad and handle on roda
      raise Buzzn::StaleEntity.new(resource.object)
    else
      resource.object.update!(input)
      Dry::Monads.Right(resource)
    end
  rescue => e
    # TODO better a Left Monad and handle on roda
    raise e
  end
end
