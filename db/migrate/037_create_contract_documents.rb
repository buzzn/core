require 'buzzn/schemas/constraints/document/contract_document'

class CreateContractDocuments < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Document::ContractDocument)

  def up
    SCHEMA.up(:contract_documents, self)

    add_belongs_to :contract_documents, :document, index: true, null: false
    add_belongs_to :contract_documents, :contract, index: true, null: false

    add_foreign_key :contract_documents, :documents, name: :fk_contract_documents_document, column: :document_id
    add_foreign_key :contract_documents, :contracts, name: :fk_contract_documents_contract, column: :contract_id
    add_index :contract_documents, [:contract_id, :document_id], unique: true
  end

end
