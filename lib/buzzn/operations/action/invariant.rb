require_relative '../action'

class Operations::Action::Invariant

  include Dry::Transaction::Operation

  def call(object:, **)
    result = invariant(object)
    unless result.success?
      object.reload
      raise Buzzn::ValidationError.new(result.errors, object)
    end
  end

  private

  ALWAYS_SUCCESS = OpenStruct.new(success?: true)

  def invariant(object)
    if invariant = object.invariant
      invariant
    else
      ALWAYS_SUCCESS
    end
  end

end
