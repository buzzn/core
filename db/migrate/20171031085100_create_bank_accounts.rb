 require 'buzzn/schemas/constraints/bank_account'

class CreateBankAccounts < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::BankAccount)

  def up
    SCHEMA.up(:bank_accounts, self)

    add_belongs_to :bank_accounts, :owner_person, reference: :persons, type: :uuid, index: true, null: true
    add_belongs_to :bank_accounts, :owner_organization, reference: :organizations, type: :uuid, index: true, null: true

    add_foreign_key :bank_accounts, :persons, name: :fk_bank_accounts_person, column: :owner_person_id
    add_foreign_key :bank_accounts, :organizations, name: :fk_bank_accounts_organization, column: :owner_organization_id

    execute 'ALTER TABLE bank_accounts ADD CONSTRAINT check_bank_account_owner CHECK (NOT (owner_person_id IS NOT NULL AND owner_organization_id IS NOT NULL))'
  end

  def down
    execute 'ALTER TABLE bank_accounts DROP CONSTRAINT check_bank_account_owner'

    remove_foreign_key :bank_accounts, :persons, name: :fk_bank_accounts_person
    remove_foreign_key :bank_accounts, :organizations, name: :fk_bank_accounts_organization

    remove_belongs_to :bank_accounts, :persons, type: :uuid, index: true, null: false
    remove_belongs_to :bank_accounts, :organizations, type: :uuid, index: true, null: false

    SCHEMA.down(:bank_accounts, self)
  end
end
