require_relative '../action'

class Operations::Action::Assign

  include Dry::Transaction::Operation

  def call(params:, resource: nil, **)
    raise ArgumentError.new('missing resource') unless resource

    # we deliver only millis to client and have to nil the nanos
    if (resource.object.updated_at.to_f * 1000).to_i != (params.delete(:updated_at).to_f * 1000).to_i
      # TODO better a Left Monad and handle on roda
      raise Buzzn::StaleEntity.new(resource.object)
    else
      assign(params, resource)
    end
  end

  private

  def assign(params, resource)
    resource.object.attributes = params
    result = invariant(resource.object)
    unless result.success?
      resource.object.reload
      p result.errors
      raise Buzzn::ValidationError.new(result.errors)
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
