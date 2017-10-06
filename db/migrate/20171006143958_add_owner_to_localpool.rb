class AddOwnerToLocalpool < ActiveRecord::Migration
  def change
    add_belongs_to :groups, :organization, index: true, type: :uuid, null: true
    add_foreign_key :groups, :organizations, name: :fk_groups_organization

    add_belongs_to :groups, :person, column: :persons_id, references: :persons, index: true, type: :uuid, null: true
    add_foreign_key :groups, :persons, column: :person_id, name: :fk_groups_person
  end
end
