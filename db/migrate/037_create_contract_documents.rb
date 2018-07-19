class CreateContractDocuments < ActiveRecord::Migration

  def up
    create_table :contracts_documents, id: false do |t|
      t.integer :contract_id, null: false
      t.integer :document_id, null: false
    end

    add_foreign_key :contracts_documents, :documents, name: :fk_contract_documents_document, column: :document_id
    add_foreign_key :contracts_documents, :contracts, name: :fk_contract_documents_contract, column: :contract_id
    add_index :contracts_documents, [:contract_id, :document_id], unique: true
  end

end
