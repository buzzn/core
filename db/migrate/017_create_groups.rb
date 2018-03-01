 require 'buzzn/schemas/constraints/group'

class CreateGroups < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Group)

  def up
    SCHEMA.up(:groups, self)

    add_column :groups, :type, :string, null: false, limit: 64
    add_column :groups, :slug, :string, null: false, limit: 64

    add_belongs_to :groups, :address, index: true, null: true

    add_belongs_to :groups, :owner_person, reference: :persons, index: true, null: true
    add_belongs_to :groups, :owner_organization, reference: :organizations, index: true, null: true
    add_belongs_to :groups, :gap_contract_customer_person, reference: :persons, index: true, null: true
    add_belongs_to :groups, :gap_contract_customer_organization, reference: :organizations, index: true, null: true

    add_belongs_to :groups, :distribution_system_operator, reference: :organizations, index: true, null: true
    add_belongs_to :groups, :transmission_system_operator, reference: :organizations, index: true, null: true
    add_belongs_to :groups, :electricity_supplier, reference: :organizations, index: true, null: true

    add_belongs_to :groups, :bank_account, reference: :bank_accounts, index: true, null: true

    add_foreign_key :groups, :addresses, name: :fk_groups_address

    add_foreign_key :groups, :persons, name: :fk_groups_owner_person, column: :owner_person_id
    add_foreign_key :groups, :organizations, name: :fk_groups_owner_organization, column: :owner_organization_id

    add_foreign_key :groups, :persons, name: :fk_groups_gap_contract_customer_person, column: :gap_contract_customer_person_id
    add_foreign_key :groups, :organizations, name: :fk_groups_gap_contract_customer_organization, column: :gap_contract_customer_organization_id

    add_foreign_key :groups, :organizations, name: :fk_groups_distribution_system_operator, column: :distribution_system_operator_id
    add_foreign_key :groups, :organizations, name: :fk_groups_transmission_system_operator, column: :transmission_system_operator_id
    add_foreign_key :groups, :organizations, name: :fk_groups_electricity_supplier, column: :electricity_supplier_id

    add_index :groups, [:slug], unique: true

    execute 'ALTER TABLE groups ADD CONSTRAINT check_localpool_owner CHECK (NOT (owner_person_id IS NOT NULL AND owner_organization_id IS NOT NULL))'
    execute 'ALTER TABLE groups ADD CONSTRAINT check_localpool_gap_contract_customer CHECK (NOT (gap_contract_customer_person_id IS NOT NULL AND gap_contract_customer_organization_id IS NOT NULL))'
  end

  def down
    execute 'ALTER TABLE groups DROP CONSTRAINT check_localpool_owner'

    remove_index :groups, [:slug], unique: true

    remove_foreign_key :groups, :addresses, name: :fk_groups_address
    remove_foreign_key :groups, :persons, name: :fk_groups_person
    remove_foreign_key :groups, :organizations, name: :fk_groups_organization

    remove_belongs_to :groups, :addresses, index: true
    remove_belongs_to :groups, :persons, index: true
    remove_belongs_to :groups, :organizations, index: true

    SCHEMA.down(:groups, self)
  end

end
