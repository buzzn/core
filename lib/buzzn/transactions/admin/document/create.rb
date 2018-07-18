require_relative '../document'
require_relative '../../../schemas/transactions/admin/document/create'

class Transactions::Admin::Document::Create < Transactions::Base

  check :authorize, with: :'operations.authorization.create'
  validate :schema
  map :create_document, with: 'operations.action.create_item'

  def schema
    Schemas::Transactions::Admin::Document::Create
  end

  def allowed_roles(permission_context:)
    permission_context.create
  end

  def create_document(resource:, params:)
    params_tmp = {
      data: params[:file][:tempfile].read,
      filename: params[:file][:filename]
    }
    DocumentResource.new(
      *super(resource, params_tmp)
    )
  end

end
