require_relative '../group_resource'
require_relative 'price_resource'
require_relative 'billing_cycle_resource'
module Admin
  class LocalpoolResource < ::GroupResource

    model Group::Localpool

    attributes :updatable, :deletable

    has_one :localpool_processing_contract
    has_one :metering_point_operator_contract
    has_many :meters
    has_many :managers
    has_many :localpool_power_taker_contracts
    has_many :users
    has_many :organizations
    has_many :contracts
    has_many :registers
    has_many :people
    has_many :prices, PriceResource
    has_many :billing_cycles, BillingCycleResource

    # API methods for endpoints

    def create_price(params = {})
      create(permissions.prices.create) do
        params[:localpool] = object
        to_resource(Price.create!(params), permissions.prices, PriceResource)
      end
    end

    def create_billing_cycle(params = {})
      create(permissions.billing_cycles.create) do
        params[:localpool] = object
        to_resource(BillingCycle.create!(params), permissions.billing_cycles,
                    BillingCycleResource)
      end
    end
  end
end
