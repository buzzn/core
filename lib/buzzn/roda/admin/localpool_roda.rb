require_relative '../admin_roda'
require_relative '../plugins/aggregation'
module Admin
  class LocalpoolRoda < BaseRoda
    PARENT = :localpool

    include Import.args[:env,
                        'transaction.charts']

    plugin :shared_vars
    plugin :aggregation

    route do |r|

      localpools = LocalpoolResource.all(current_user)

      r.root do
        localpools
      end

      r.on :id do |id|

        shared[PARENT] = localpool = localpools.retrieve(id)

        r.on 'contracts' do
          r.run ContractRoda
        end

        r.on 'registers' do
          shared[:registers] = localpool.registers
          r.run ::RegisterRoda
        end

        r.on 'meters' do
          r.run MeterRoda
        end

        r.on 'persons' do
          r.run PersonRoda
        end

        r.on 'organizations' do
          r.run OrganizationRoda
        end

        r.on 'prices' do
          r.run PriceRoda
        end

        r.on 'billing-cycles' do
          r.run BillingCycleRoda
        end

        r.get! do
          localpool
        end

        r.get! 'localpool-processing-contract' do
          localpool.localpool_processing_contract!
        end

        r.get! 'metering-point-operator-contract' do
          localpool.metering_point_operator_contract!
        end

        r.get! 'power-taker-contracts' do
          localpool.localpool_power_taker_contracts
        end

        r.get! 'managers' do
          localpool.managers
        end

        r.get! 'charts' do
          aggregated(charts.call(r.params,
                                 resource: [localpool.method(:charts)]))
        end

        r.get! 'bubbles' do
          aggregated(localpool.bubbles)
        end

      end
    end
  end
end
