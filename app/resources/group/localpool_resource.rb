module Group
  class LocalpoolResource < BaseResource

    model Localpool

    has_one :localpool_processing_contract
    has_one :metering_point_operator_contract

    def prices
      object.prices.readable_by(@current_user).collect { |pr| PriceResource.new(pr) }
    end

    def create_price(params = {})
      params[:localpool] = object
      PriceResource.new(Price.guarded_create(@current_user, params, object))
    end

    # API methods

    def power_taker_contracts
      object.localpool_power_taker_contracts
        .readable_by(@current_user)
        .collect { |c| self.class.to_resource(@current_user, c) }
    end

    def create_billing_cycle(params = {})
      params[:localpool] = object
      BillingCycleResource.new(BillingCycle.guarded_create(@current_user, params, object))
    end

    def billing_cycles
      object.billing_cycles.readable_by(@current_user).collect { |bc| BillingCycleResource.new(bc) }
    end
  end
end
