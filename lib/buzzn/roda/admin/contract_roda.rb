require_relative '../admin_roda'

module Admin
  class ContractRoda < BaseRoda

    include Import.args[:env,
                        'transactions.admin.contract.document',
                        'transactions.admin.contract.create_localpool_processing',
                       ]

    plugin :shared_vars
    plugin :param_matchers

    PARENT = :contract

    route do |r|

      localpool = shared[LocalpoolRoda::PARENT]
      contracts = localpool.contracts
      localpool_processing_contracts = localpool.localpool_processing_contracts

      r.on :id do |id|

        shared[PARENT] = contract = contracts.retrieve(id)

        r.get! do
          contract
        end

        r.get! 'contractor' do
          contract.contractor!
        end

        r.get! 'customer' do
          contract.customer!
        end

        r.post! 'documents/generate' do
          document.(resource: contract, params: r.params)
        end

        r.on 'documents' do
          shared[:documents] = contract.documents
          r.run DocumentRoda
        end

      end

      r.get! do
        case r.params['type'].to_s
        when 'contract_localpool_processing'
          localpool.localpool_processing_contracts
        when 'contract_power_taker'
          localpool.localpool_power_taker_contracts
        when 'contract_metering_point_operator'
          localpool.metering_point_operator_contracts
        else
          contracts
        end
      end

      r.post!(:param=>'type') do |type|
        case type.to_s
        when 'contract_localpool_processing'
          create_localpool_processing.(resource: localpool_processing_contracts, params: r.params, localpool: localpool)
        else
          r.response.status = 400
        end
      end

    end

  end
end
