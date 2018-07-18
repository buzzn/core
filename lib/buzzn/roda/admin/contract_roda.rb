require_relative '../admin_roda'

module Admin
  class ContractRoda < BaseRoda

    include Import.args[:env,
                        'transactions.admin.contract.document'
                       ]

    plugin :shared_vars

    PARENT = :contract

    route do |r|

      contracts = shared[LocalpoolRoda::PARENT].contracts

      r.get! do
        contracts
      end

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

        r.post! 'document' do
          document.(resource: contract, params: r.params)
        end

        r.on 'documents' do
          shared[:documents] = contract.documents
          r.run DocumentRoda
        end

      end
    end

  end
end
