require 'buzzn/schemas/constraints/document/group_document'

class CreateGroupDocuments < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Document::GroupDocument)

  def up
    SCHEMA.up(:groups_documents, self)

    add_belongs_to :groups_documents, :document, index: true, null: false
    add_belongs_to :groups_documents, :group, index: true, null: false

    add_foreign_key :groups_documents, :documents, name: :fk_groups_documents_document, column: :document_id
    add_foreign_key :groups_documents, :groups, name: :fk_groups_documents_group, column: :group_id
    add_index :groups_documents, [:document_id, :group_id], unique: true
  end

end
