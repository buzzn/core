require_relative '../contract_document'
require_relative '../../../schemas/transactions/admin/contract/document/create'

class Transactions::Admin::ContractDocument::Create < Transactions::Base

  check :authorize, with: :'operations.authorization.create'
  validate :schema
  map :create_document, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::Admin::Contract::Document::Create
  end

  def allowed_roles(permission_context:)
    permission_context.create
  end

  def create_document(resource:, contract:, params:)
    content = params[:file][:tempfile].read
    doc = Document.create(filename: params[:file][:filename], data: content)
    ContractDocument.create(contract_id: contract.id, document_id: doc.id)
    # return doc
    DocumentResource.new(doc)
  end

end
