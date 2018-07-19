require 'buzzn/schemas/constraints/document/billing_document'

class CreateBillingDocuments < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Document::BillingDocument)

  def up
    SCHEMA.up(:billing_documents, self)

    add_belongs_to :billing_documents, :document, index: true, null: false
    add_belongs_to :billing_documents, :billing, index: true, null: false

    add_foreign_key :billing_documents, :documents, name: :fk_billing_documents_document, column: :document_id
    add_foreign_key :billing_documents, :billings, name: :fk_billing_documents_billing, column: :billing_id
    add_index :billing_documents, [:document_id, :billing_id], unique: true
  end

end
