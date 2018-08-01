require_relative '../admin_roda'

module Admin
  class DocumentRoda < BaseRoda

    include Import.args[:env,
                        'transactions.admin.document.create',
                        'transactions.admin.document.delete']

    plugin :shared_vars

    route do |r|

      documents = shared[:documents]

      r.get! do
        documents
      end

      r.post! do
        create.(resource: documents, params: r.params)
      end

      r.others!

      r.on :id do |id|

        r.get! do
          documents.retrieve(id)
        end

        r.delete! do
          document = documents.retrieve(id)
          delete.(resource: document)
        end

        r.others!

        r.get! 'fetch' do
          doc = documents.retrieve(id)
          r.response.headers['Content-Type'] = doc.mime
          r.response.headers['ETag'] = doc.sha256
          r.response.write(doc.read)
        end

      end

    end

  end
end
