module Contract
  class PowerGiverResource < BaseResource

    model PowerGiver

  end

  # TODO get rid of the need of having a Serializer class
  class PowerGiverSerializer < PowerGiverResource
  end
end
