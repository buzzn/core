require_relative '../admin_roda'
require_relative '../plugins/aggregation'

module Admin
  class LocalpoolRoda < BaseRoda

    include Import.args[:env,
                        create: 'transactions.admin.localpool.create',
                        bank_account_assign: 'transactions.admin.bank_account.assign',
                        update: 'transactions.admin.localpool.update',
                        assign_owner: 'transactions.admin.localpool.assign_owner',
                        assign_gap_contract_customer: 'transactions.admin.localpool.assign_gap_contract_customer',
                        create_person_owner: 'transactions.admin.localpool.create_person_owner',
                        create_person_gap_contract_customer: 'transactions.admin.localpool.create_person_gap_contract_customer',
                        create_gap_contracts: 'transactions.admin.contract.localpool.create_gap_contracts',
                        update_nested_person: 'transactions.admin.generic.update_nested_person',
                        update_person_owner: 'transactions.admin.localpool.update_person_owner',
                        create_organization_owner: 'transactions.admin.localpool.create_organization_owner',
                        create_organization_gap_contract_customer: 'transactions.admin.localpool.create_organization_gap_contract_customer',
                        assign_gap_contract_tariffs: 'transactions.admin.localpool.assign_gap_contract_tariffs',
                        update_nested_organization: 'transactions.admin.generic.update_nested_organization',
                        update_organization_owner: 'transactions.admin.localpool.update_organization_owner',
                        bubbles: 'transactions.bubbles',
                        delete: 'transactions.delete'
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

        r.on 'gap-contracts' do
          r.post! do
            create_gap_contracts.(resource: localpool.localpool_gap_contracts, params: r.params, localpool: localpool)
          end
          r.others!
        end

        r.on 'gap-contract-tariffs' do
          r.get! do
            localpool.contexted_gap_contract_tariffs
          end
          r.patch! do
            assign_gap_contract_tariffs.(resource: localpool, params: r.params)
          end
          r.others!
        end

        r.patch!('gap-contract-customer-bank-account') do
          bank_account_assign.(resource: localpool, params: r.params, attribute: :gap_contract_customer_bank_account, person_or_org: :gap_contract_customer)
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
            update_person_owner.(resource: localpool, params: r.params)
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
            update_organization_owner.(resource: localpool, params: r.params)
          end

          r.post! :id do |id|
            r.response.status = 201
            new_owner = AdminResource.new(current_user).organizations.retrieve(id)
            assign_owner.(resource: localpool,
                          new_owner: new_owner)
          end
        end

        r.on 'person-gap-contract-customer' do
          r.post! do
            create_person_gap_contract_customer.(resource: localpool, params: r.params)
          end

          r.patch! do
            update_nested_person.(resource: localpool.owner, params: r.params)
          end

          r.post! :id do |id|
            new_customer = AdminResource.new(current_user).persons.retrieve(id)
            assign_gap_contract_customer.(resource: localpool,
                                          new_customer: new_customer)
          end
        end

        r.on 'organization-gap-contract-customer' do
          r.post! do
            create_organization_gap_contract_customer.(resource: localpool, params: r.params)
          end

          r.patch! do
            update_nested_organization.(resource: localpool.gap_contract_customer, params: r.params)
          end

          r.post! :id do |id|
            r.response.status = 201
            new_customer = AdminResource.new(current_user).organizations.retrieve(id)
            assign_gap_contract_customer.(resource: localpool,
                                          new_customer: new_customer)
          end

        end

        r.on 'register-metas' do
          r.run RegisterMetaRoda
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
