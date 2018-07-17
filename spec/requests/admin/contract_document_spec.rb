require_relative 'test_admin_localpool_roda'
require_relative 'contract_shared'

describe Admin::LocalpoolRoda, :request_helper do

  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'contracts' do
    include_context 'contract entities'

    context 'documents' do

      entity!('contract') { localpool_processing_contract }
      let('path') { "/localpools/#{localpool.id}/contracts/#{contract.id}/documents" }

      entity!('document') { create(:document, :pdf) }
      entity!('contract_document') { create(:contract_document, contract_id: contract.id, document: document)}

      context 'list documents' do

        context 'unauthenticated' do
          it '403' do
            GET path
            expect(response).to have_http_status(403)
          end
        end

        context 'authenticated' do
          it '200' do
            GET path, $admin
            expect(response).to have_http_status(200)
          end
        end

      end

      context 'retrieves metadata of a document' do

        context 'unauthenticated' do
          it '403' do
            GET "#{path}/#{document.id}"
            expect(response).to have_http_status(403)
          end
        end

        context 'authenticated' do
          it '200' do
            GET "#{path}/#{document.id}", $admin
            expect(response).to have_http_status(200)
          end
        end

      end

      context 'fetches a document' do

        context 'unauthenticated' do
          it '403' do
            GET "#{path}/#{document.id}/fetch"
            expect(response).to have_http_status(403)
          end
        end

        context 'authenticated' do
          it '200' do
            GET "#{path}/#{document.id}/fetch", $admin
            expect(response).to have_http_status(200)
            expect(response.headers['Content-Type']).to eq 'application/pdf'
            expect(response.headers['ETag']).not_to eq nil
            expect(response.body[0..7]).to eq '%PDF-1.4'
          end
        end

      end

      context 'deletes a document' do

        entity!('deletable_document') { create(:document, :png) }
        entity!('deletable_contract_document') { create(:contract_document, contract_id: contract.id, document: deletable_document)}

        let('document_id') { deletable_document.id }
        let('contract_document_id') { deletable_contract_document.id }

        context 'unauthenticated' do
          it '403' do
            DELETE "#{path}/#{document_id}"
            expect(response).to have_http_status(403)
          end
        end

        context 'authenticated' do
          it '200' do
            DELETE "#{path}/#{document_id}", $admin
            expect(response).to have_http_status(204)
            expect { Document.find(document_id) }.to raise_error ActiveRecord::RecordNotFound
            expect { ContractDocument.find(contract_document_id) }.to raise_error ActiveRecord::RecordNotFound
          end
        end

      end

      context 'create a document' do

        context 'unauthenticated' do
          it '403' do
            POST_FILE path, document.filename, document.read, document.mime
            expect(response).to have_http_status(403)
          end
        end

        context 'authenticated' do
          context 'with valid data' do
            it '201' do
              POST_FILE path, document.filename, document.read, document.mime, $admin
              expect(response).to have_http_status(200)
            end
          end

          context 'with invalid data' do
            it '422' do
              POST path, $admin, { 'foo' => 'bar' }
              expect(response).to have_http_status(422)
            end
          end

        end
      end

    end
  end

end
