require_relative '../action'

class Operations::Action::Stale

  include Dry::Transaction::Operation

  def call(params:, resource:, **)
    # we deliver only millis to client and have to nil the nanos
    if (resource.object.updated_at.to_f * 1000).to_i != (params.delete(:updated_at).to_f * 1000).to_i
      # TODO better a Left Monad and handle on roda
      raise Buzzn::StaleEntity.new(resource.object)
    end
  end

end
