require 'buzzn/schemas/constraints/pdf_document'

class CreatePdfDocuments < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::PdfDocument)

  def up
    SCHEMA.up(:pdf_documents, self)

    add_belongs_to :pdf_documents, :template, index: true, null: false
    add_belongs_to :pdf_documents, :document, index: true, null: false

    add_foreign_key :pdf_documents, :templates, name: :fk_pdf_documents_template, column: :template_id
    add_foreign_key :pdf_documents, :documents, name: :fk_pdf_documents_document, column: :document_id
  end

  def down
    raise 'not implemented'
  end

end
