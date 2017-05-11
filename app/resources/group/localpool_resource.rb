module Group
  class LocalpoolResource < BaseResource

    model Localpool

    has_one :localpool_processing_contract
    has_one :metering_point_operator_contract
    has_many :localpool_power_taker_contracts
    has_many :prices
    has_many :billing_cycles

    def create_price(params = {})
      params[:localpool] = object
      PriceResource.new(Price.guarded_create(@current_user, params, object))
    end

    def create_billing_cycle(params = {})
      params[:localpool] = object
      BillingCycleResource.new(BillingCycle.guarded_create(@current_user, params, object))
    end
  end
end
