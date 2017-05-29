module Group
  class LocalpoolResource < BaseResource

    model Localpool

    has_one :localpool_processing_contract
    has_one :metering_point_operator_contract
    has_many :localpool_power_taker_contracts
    has_many :prices
    has_many :billing_cycles
    has_many :localpool_power_taker_contracts
    has_many :users
    has_many :contracts
    has_many :registers
    has_many :users
    has_many :prices
    has_many :billing_cycles

    def create_price(params = {})
      create(permissions.prices.create) do
        params[:localpool] = object
        to_resource(Price.create!(params), permissions.prices)
      end
    end

    def create_billing_cycle(params = {})
      create(permissions.billing_cycles.create) do
        params[:localpool] = object
        to_resource(BillingCycle.create!(params), permissions.billing_cycles)
      end
    end
  end
end
