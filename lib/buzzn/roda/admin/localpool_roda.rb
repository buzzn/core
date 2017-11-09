require_relative '../admin_roda'
require_relative '../plugins/aggregation'
require_relative '../../transactions/bubbles'
require_relative '../../transactions/group_chart'
require_relative '../../transactions/admin/localpool/create'
require_relative '../../transactions/admin/localpool/update'

module Admin
  class LocalpoolRoda < BaseRoda
    PARENT = :localpool

    plugin :shared_vars
    plugin :aggregation

    route do |r|

      localpools = LocalpoolResource.all(current_user)

      r.on :id do |id|

        shared[PARENT] = localpool = localpools.retrieve(id)

        # NOTE: registers does not check on session expiration
        #       as it is used by bubbles and charts
        r.on 'registers' do
          shared[:registers] = localpool.registers
          r.run ::RegisterRoda
        end

        r.get! 'charts' do
          aggregated(
            Transactions::GroupChart
              .for(localpool)
              .call(r.params).value
          )
        end

        r.get! 'bubbles' do
          aggregated(
            Transactions::Bubbles
              .call(localpool).value
          )
        end

        rodauth.check_session_expiration

        r.patch! do
          Transactions::Admin::Localpool::Update
            .for(localpool)
            .call(r.params)
        end

        r.on 'contracts' do
          r.run ContractRoda
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

        r.on 'tariffs' do
          r.run TariffRoda
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

        r.on 'person_owner' do
          r.post! do
            Transactions::Admin::Localpool::CreatePersonOwner
              .for(localpool)
              .call(r.params)
          end

          r.post! :id do |id|
            Transactions::Admin::Localpool::AssignOwner
              .for(localpool)
              .call(localpool.persons.retrieve(id))
          end
        end

        r.on 'organization_owner' do
          r.post! do
            Transactions::Admin::Localpool::CreateOrganizationOwner
              .for(localpool)
              .call(r.params)
          end

          r.post! :id do |id|
            Transactions::Admin::Localpool::AssignOwner
              .for(localpool)
              .call(localpool.organizations.retrieve(id))
          end
        end
      end

      rodauth.check_session_expiration

      r.get! do
        localpools
      end

      r.post! do
        Transactions::Admin::Localpool::Create
          .for(localpools)
          .call(r.params)
      end
    end
  end
end
