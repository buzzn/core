module Group
  class LocalpoolResource < BaseResource

    include Import.reader['service.current_power',
                          'service.charts']

    model Localpool

    has_one :localpool_processing_contract
    has_one :metering_point_operator_contract
    has_many :localpool_power_taker_contracts
    has_many :prices
    has_many :billing_cycles
    has_many :localpool_power_taker_contracts
    has_many :users
    has_many :organizations
    has_many :contracts
    has_many :registers
    has_many :users
    has_many :prices
    has_many :billing_cycles

    # API methods for endpoints

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

    def bubbles
      current_power.for_each_register_in_group(self)
    end

    def charts(duration:, timestamp: nil)
      @charts.for_group(self, Buzzn::Interval.create(duration, timestamp))
    end

  end
end
