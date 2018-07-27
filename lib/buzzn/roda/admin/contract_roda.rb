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

        r.get! { contract }

        r.get!('contractor') { contract.contractor! }

        r.get!('customer') { contract.customer! }

        r.on 'documents' do

          r.on 'generate' do
            r.post! { document.(resource: contract, params: r.params) }
            r.others!
          end

          shared[:documents] = contract.documents
          r.run DocumentRoda
        end

      end

      r.get! { contracts }

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
