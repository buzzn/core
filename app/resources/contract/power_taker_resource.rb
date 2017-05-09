module Contract
  class PowerTakerResource < BaseResource

    model PowerTaker

  end

  # TODO get rid of the need of having a Serializer class
  class PowerTakerSerializer < PowerTakerResource
  end
end
