require 'buzzn/schemas/constraints/document/billing_document'

class CreateBillingDocuments < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Document::BillingDocument)

  def up
    SCHEMA.up(:billings_documents, self)

    add_belongs_to :billings_documents, :document, index: true, null: false
    add_belongs_to :billings_documents, :billing, index: true, null: false

    add_foreign_key :billings_documents, :documents, name: :fk_billings_documents_document, column: :document_id
    add_foreign_key :billings_documents, :billings, name: :fk_billings_documents_billing, column: :billing_id
    add_index :billings_documents, [:document_id, :billing_id], unique: true
  end

end
