module Group
  class LocalpoolResource < MinimalBaseResource

    model Group::Localpool

    has_one :localpool_processing_contract
    has_one :metering_point_operator_contract

  end

  # TODO get rid of the need of having a Serializer class
  class LocalpoolSerializer < LocalpoolResource
    def self.new(*args)
      super
    end
  end
end
