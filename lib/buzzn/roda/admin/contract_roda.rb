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
          rdoc = document.(
            resource: contract, params: r.params
          )
          if rdoc.success?
            res = rdoc.value!
            # res.document is a ContractDocument
            r.response.status = 201 # created
            r.response.headers['Location'] = "/localpools/#{contract.localpool_id}/contract/#{contract.id}/documents/#{res[:document].document_id}"
            ''
          else
            r.response.status = 500
          end
        end

      end
    end

  end
end
