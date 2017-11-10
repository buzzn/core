require_relative '../admin_roda'
require_relative '../plugins/aggregation'
module Admin
  class LocalpoolRoda < BaseRoda
    PARENT = :localpool

    include Import.args[:env,
                        'transaction.charts',
                        'transaction.create_localpool',
                        'transaction.update_localpool']

    plugin :shared_vars
    plugin :aggregation
    plugin :created_deleted

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
          aggregated(charts.call(r.params,
                                 resource: [localpool.method(:charts)]))
        end

        r.get! 'bubbles' do
          aggregated(localpool.bubbles)
        end

        rodauth.check_session_expiration

        r.patch! do
          update_localpool.call(r.params, resource: [localpool])
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
            create_localpool_owner.call(r.params,
                                        validate: [Schemas::Transactions::Person::Create],
                                        build: [localpool.persons],
                                        assign: [localpool.method(:assign_owner)])
          end

          r.post! :id do |id|
            assign_localpool_owner.call(id,
                                        find: [localpool.persons],
                                        assign: [localpool.method(:assign_owner)])
          end
        end

        r.on 'organization_owner' do
          r.post! do
            create_localpool_owner.call(r.params,
                                        validate: [OrganizationContraints],
                                        build: [localpool.organizations],
                                        assign: [localpool.method(:assign_owner)])
          end

          r.post! :id do |id|
            assign_localpool_owner.call(localpool.organizations.retrieve(id),
                                        assign: [localpool.method(:assign_owner)])
          end
        end
      end

      rodauth.check_session_expiration

      r.get! do
        localpools
      end

      r.post! do
        created do
          create_localpool.call(r.params,
                                resource: [localpools.method(:create)])
        end
      end
    end
  end
end
