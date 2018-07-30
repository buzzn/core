require_relative '../admin_roda'
require_relative '../plugins/aggregation'

module Admin
  class LocalpoolRoda < BaseRoda

    include Import.args[:env,
                        'transactions.admin.localpool.create',
                        'transactions.admin.localpool.update',
                        'transactions.admin.localpool.assign_owner',
                        'transactions.admin.localpool.create_person_owner',
                        'transactions.admin.localpool.update_person_owner',
                        'transactions.admin.localpool.create_organization_owner',
                        'transactions.admin.localpool.update_organization_owner',
                        'transactions.bubbles',
                        'transactions.delete'
                       ]

    PARENT = :localpool

    plugin :shared_vars
    plugin :aggregation

    route do |r|

      localpools = LocalpoolResource.all(current_user)

      r.on :id do |id|

        shared[PARENT] = localpool = localpools.retrieve(id)

        r.get! 'bubbles' do
          aggregated(bubbles.(localpool).value!)
        end

        r.patch! do
          update.(resource: localpool, params: r.params)
        end

        r.delete! do
          delete.(resource: localpool)
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

        r.on 'devices' do
          r.run Admin::DeviceRoda
        end

        r.get! do
          localpool
        end

        r.get! 'managers' do
          localpool.managers
        end

        r.on 'person-owner' do
          r.post! do
            create_person_owner.(resource: localpool, params: r.params)
          end

          r.patch! do
            update_person_owner.(resource: localpool.owner, params: r.params)
          end

          r.post! :id do |id|
            new_owner = AdminResource.new(current_user).persons.retrieve(id)
            assign_owner.(resource: localpool,
                          new_owner: new_owner)
          end
        end

        r.on 'organization-owner' do
          r.post! do
            create_organization_owner.(resource: localpool, params: r.params)
          end

          r.patch! do
            r.response.status = 200
            update_organization_owner.(resource: localpool.owner, params: r.params)
          end

          r.post! :id do |id|
            r.response.status = 201
            new_owner = AdminResource.new(current_user).organizations.retrieve(id)
            assign_owner.(resource: localpool,
                          new_owner: new_owner)
          end
        end

        r.on 'market-locations' do
          r.run MarketLocationRoda
        end
      end

      rodauth.check_session_expiration

      r.get! do
        localpools
      end

      r.post! do
        create.(resource: localpools, params: r.params)
      end
    end

  end
end
