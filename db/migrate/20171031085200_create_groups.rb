 require 'buzzn/schemas/constraints/group'

class CreateGroups < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::Group)

  def up
    SCHEMA.up(:groups, self)

    add_column :groups, :type, :string, null: false, size: 64
    add_column :groups, :slug, :string, null: false, size: 64

    add_belongs_to :groups, :address, type: :uuid, index: true, null: false
    add_belongs_to :groups, :person, type: :uuid, index: true, null: true
    add_belongs_to :groups, :organization, type: :uuid, index: true, null: true

    add_foreign_key :groups, :addresses, name: :fk_groups_address
    add_foreign_key :groups, :persons, name: :fk_groups_person
    add_foreign_key :groups, :organizations, name: :fk_groups_organization

    add_index :groups, [:slug], unique: true

    execute 'ALTER TABLE groups ADD CONSTRAINT check_localpool_owner CHECK (NOT (person_id IS NOT NULL AND organization_id IS NOT NULL))'
  end

  def down
    execute 'ALTER TABLE groups DROP CONSTRAINT check_localpool_owner'

    remove_index :groups, [:slug], unique: true

    remove_foreign_key :groups, :addresses, name: :fk_groups_address
    remove_foreign_key :groups, :persons, name: :fk_groups_person
    remove_foreign_key :groups, :organizations, name: :fk_groups_organization

    remove_belongs_to :groups, :addresses, type: :uuid, index: true, null: false
    remove_belongs_to :groups, :persons, type: :uuid, index: true, null: false
    remove_belongs_to :groups, :organizations, type: :uuid, index: true, null: false

    SCHEMA.down(:groups, self)
  end
end
