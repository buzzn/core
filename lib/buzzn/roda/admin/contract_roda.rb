require_relative '../admin_roda'

module Admin
  class ContractRoda < BaseRoda

    include Import.args[:env,
                        'transactions.admin.contract.document',
                        'transactions.admin.contract.localpool.create_processing',
                        'transactions.admin.contract.localpool.update_processing',
                        'transactions.admin.contract.localpool.create_power_taker_assign',
                        'transactions.admin.contract.localpool.create_power_taker_with_person',
                        'transactions.admin.contract.localpool.create_power_taker_with_organization',
                        'transactions.admin.contract.localpool.update_power_taker',
                        'transactions.admin.contract.localpool.create_metering_point_operator',
                        'transactions.admin.contract.localpool.update_metering_point_operator',
                        'transactions.admin.generic.update_nested_person',
                        'transactions.admin.generic.update_nested_organization',
                       ]

    plugin :shared_vars
    plugin :param_matchers

    PARENT = :contract

    route do |r|

      localpool = shared[LocalpoolRoda::PARENT]
      contracts = localpool.contracts
      localpool_processing_contracts = localpool.localpool_processing_contracts
      localpool_power_taker_contracts = localpool.localpool_power_taker_contracts
      metering_point_operator_contracts = localpool.metering_point_operator_contracts

      r.on :id do |id|

        shared[PARENT] = contract = contracts.retrieve(id)

        r.get! do
          contract
        end

        r.patch! do
          case contract
          when Contract::LocalpoolProcessingResource
            update_processing.(resource: contract, params: r.params)
          when Contract::LocalpoolPowerTakerResource
            update_power_taker.(resource: contract, params: r.params)
          when Contract::MeteringPointOperatorResource
            update_metering_point_operator.(resource: contract, params: r.params)
          else
            r.response.status = 400
          end
        end

        r.get! 'contractor' do
          contract.contractor!
        end

        r.get!('contractor') { contract.contractor! }

        r.get!('customer') { contract.customer! }

        r.patch!('customer-person') do
          case contract
          when Contract::LocalpoolPowerTakerResource
            update_nested_person.(resource: contract.customer, params: r.params)
          else
            r.response.status = 400
          end
        end

        r.patch!('customer-organization') do
          case contract
          when Contract::LocalpoolPowerTakerResource
            update_nested_organization.(resource: contract.customer, params: r.params)
          else
            r.response.status = 400
          end
        end

        r.on 'documents' do

          r.on 'generate' do
            r.post! { document.(resource: contract, params: r.params) }
            r.others!
          end

          shared[:documents] = contract.documents
          r.run DocumentRoda
        end

        r.on 'billings' do
          shared[:billings] = contract.billings
          shared[:parent] = contract.object
          r.run BillingRoda
        end

      end

      r.get! do
        case r.params['type'].to_s
        when 'contract_localpool_processing'
          localpool_processing_contracts
        when 'contract_localpool_power_taker'
          localpool_power_taker_contracts
        when 'contract_metering_point_operator'
          metering_point_operator_contracts
        else
          contracts
        end
      end

      r.post!(:param=>'type') do |type|
        case type.to_s
        when 'contract_localpool_processing'
          create_processing.(resource: localpool_processing_contracts, params: r.params, localpool: localpool)
        when 'contract_metering_point_operator'
          create_metering_point_operator.(resource: metering_point_operator_contracts, params: r.params, localpool: localpool)
        when 'contract_localpool_power_taker'
          # we have 3 cases here:
          # assign with an id
          # create with an organization as customer
          # create with a  person as customer
          if r.params['customer'].nil?
            # TODO error
            r.response.status = 422
            raise Buzzn::ValidationError.new(customer: ['must be filled'])
          else
            if !r.params['customer']['id'].nil?
              create_power_taker_assign.(resource: localpool_power_taker_contracts, params: r.params, localpool: localpool)
            elsif r.params['customer']['type'] == 'organization'
              create_power_taker_with_organization.(resource: localpool_power_taker_contracts, params: r.params, localpool: localpool)
            else # default to person
              create_power_taker_with_person.(resource: localpool_power_taker_contracts, params: r.params, localpool: localpool)
            end
          end
        else
          r.response.status = 400
        end
      end

      # without a type
      r.post! do
        r.response.status = 400
      end

    end

  end
end
