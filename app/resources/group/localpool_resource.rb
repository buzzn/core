module Group
  class LocalpoolResource < MinimalBaseResource

    model Localpool

    has_one :localpool_processing_contract
    has_one :metering_point_operator_contract

    def prices
      object.prices.readable_by(@current_user).collect { |pr| PriceResource.new(pr) }
    end

    def create_price(params = {})
      Price.guarded_create(@current_user, params)
    end

  end

  # TODO get rid of the need of having a Serializer class
  class LocalpoolSerializer < LocalpoolResource
  end
end
