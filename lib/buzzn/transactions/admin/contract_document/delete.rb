require_relative '../contract_document'
require_relative '../../delete'

class Transactions::Admin::ContractDocument::Delete < Transactions::Base

  check :authorize, with: :'operations.authorization.delete'
  map :delete_document

  def delete_document(resource:, contract:)
    cd = ContractDocument.where(:contract_id => contract.id, :document_id => resource.id).first
    cd.destroy
    resource.destroy
    resource
  end

end
