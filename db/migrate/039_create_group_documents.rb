require 'buzzn/schemas/constraints/document/group_document'

class CreateGroupDocuments < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Document::GroupDocument)

  def up
    SCHEMA.up(:group_documents, self)

    add_belongs_to :group_documents, :document, index: true, null: false
    add_belongs_to :group_documents, :group, index: true, null: false

    add_foreign_key :group_documents, :documents, name: :fk_group_documents_document, column: :document_id
    add_foreign_key :group_documents, :groups, name: :fk_group_documents_group, column: :group_id
    add_index :group_documents, [:document_id, :group_id], unique: true
  end
end
