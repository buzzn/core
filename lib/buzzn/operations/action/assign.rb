require_relative '../action'

class Operations::Action::Assign

  include Dry::Transaction::Operation

  def call(input, resource = nil)
    raise ArgumentError.new('missing resource') unless resource

    # we deliver only millis to client and have to nil the nanos
    if (resource.object.updated_at.to_f * 1000).to_i != (input.delete(:updated_at).to_f * 1000).to_i
      # TODO better a Left Monad and handle on roda
      raise Buzzn::StaleEntity.new(resource.object)
    else
      assign(input, resource)
    end
  end

  private

  def assign(input, resource)
    resource.object.attributes = input
    result = invariant(resource.object)
    if result.success?
      Success(resource)
    else
      resource.object.reload
      Failure(result)
    end
  end

  ALWAYS_SUCCESS = OpenStruct.new(success?: true)

  def invariant(object)
    if invariant = object.invariant
      invariant
    else
      ALWAYS_SUCCESS
    end
  end

end
