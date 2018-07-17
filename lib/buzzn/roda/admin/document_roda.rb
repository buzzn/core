require_relative '../admin_roda'

module Admin
  class DocumentRoda < BaseRoda

    include Import.args[:env,
                        'transactions.admin.contract_document.create',
                        'transactions.admin.contract_document.delete']

    plugin :shared_vars

    route do |r|

      contract = shared[ContractRoda::PARENT]

      r.get! do
        contract.documents
      end

      r.post! do
        create.(resource: contract.documents, params: r.params, contract: contract)
      end

      r.on :id do |id|

        r.get! do
          contract.documents.retrieve(id)
        end

        r.delete! do
          document = contract.documents.retrieve(id)
          delete.(resource: document, contract: contract)
        end

        r.get! 'fetch' do
          doc = contract.documents.retrieve(id)
          r.response.headers['Content-Type'] = doc.mime
          r.response.headers['ETag'] = doc.sha256
          r.response.write(doc.read)
        end

      end

    end

  end
end
