require_relative '../group_resource'
require_relative '../person_resource'
require_relative 'price_resource'
require_relative 'billing_cycle_resource'
require_relative '../../schemas/admin/localpool_incompleteness'
module Admin
  class LocalpoolResource < GroupResource

    model Group::Localpool

    attributes :updatable, :deletable, :incompleteness

    has_one :localpool_processing_contract
    has_one :metering_point_operator_contract
    has_many :meters
    has_many :managers, PersonResource
    has_many :localpool_power_taker_contracts
    has_many :users
    has_many :organizations
    has_many :contracts
    has_many :registers
    has_many :persons
    has_many :prices, PriceResource
    has_many :billing_cycles, BillingCycleResource
    has_one :owner

    def incompleteness
      LocalpoolIncompleteness.(self).messages
    end

    # API methods for endpoints

    def create_price(params = {})
      create(permissions.prices.create) do
        to_resource(object.prices.create!(params),
                    permissions.prices,
                    PriceResource)
      end
    end

    def create_billing_cycle(params = {})
      create(permissions.billing_cycles.create) do
        to_resource(object.billing_cycles.create!(params),
                    permissions.billing_cycles,
                    BillingCycleResource)
      end
    end
  end
end
