module Contract
  class LocalpoolPowerTakerResource < BaseResource

    model LocalpoolPowerTaker

  end

  # TODO get rid of the need of having a Serializer class
  class LocalpoolPowerTakerSerializer < LocalpoolPowerTakerResource
    def self.new(*args)
      super
    end
  end
end
