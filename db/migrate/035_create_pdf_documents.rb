require 'buzzn/schemas/constraints/pdf_document'

class CreatePdfDocuments < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::PdfDocument)

  def up
    SCHEMA.up(:pdf_documents, self)

    add_belongs_to :pdf_documents, :template, index: true, null: false
    add_belongs_to :pdf_documents, :document, index: true, null: false
    add_belongs_to :pdf_documents, :localpool, reference: :groups, index: true, null: true
    add_belongs_to :pdf_documents, :contract, index: true, null: true
    add_belongs_to :pdf_documents, :billing, index: true, null: true

    add_foreign_key :pdf_documents, :templates, name: :fk_pdf_documents_template, column: :template_id
    add_foreign_key :pdf_documents, :documents, name: :fk_pdf_documents_document, column: :document_id
    add_foreign_key :pdf_documents, :groups, name: :fk_pdf_documents_localpool, column: :localpool_id
    add_foreign_key :pdf_documents, :contracts, name: :fk_pdf_documents_contract, column: :contract_id
    add_foreign_key :pdf_documents, :billings, name: :fk_pdf_documents_billing, column: :billing_id

    execute 'ALTER TABLE pdf_documents ADD CONSTRAINT check_pdf_document_relations CHECK ((localpool_id IS NOT NULL AND contract_id IS NULL AND billing_id IS NULL) OR (localpool_id IS NULL AND contract_id IS NOT NULL AND billing_id IS NULL) OR (localpool_id IS NULL AND contract_id IS NULL AND billing_id IS NOT NULL))'
  end

  def down
    raise 'not implemented'
  end

end
