class AddLegalRepresentationToOrganization < ActiveRecord::Migration
  def change
    add_belongs_to :organizations, :legal_representation, references: :persons, index: true, type: :uuid, null: true
    add_foreign_key :organizations, :persons, column: :legal_representation_id, name: :fk_organizations_legal_representation
    remove_column :organizations, :represented_by
  end
end
