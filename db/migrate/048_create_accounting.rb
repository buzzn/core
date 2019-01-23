require 'buzzn/schemas/constraints/accounting/entry'

class CreateAccounting < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Accounting::Entry)

  def up
    SCHEMA.up(:accounting_entries, self)

    add_belongs_to :accounting_entries, :contract,  reference: :contracts, null: false, index: true
    add_belongs_to :accounting_entries, :booked_by, reference: :accounts,  null: true,  index: true

    add_foreign_key :accounting_entries, :contracts, name: :fk_accounting_entries_contracts
    add_foreign_key :accounting_entries, :accounts, name: :fk_accounting_entries_accounts, column: :booked_by_id
  end

  def down
    SCHEMA.down(:accounting_entries, self)
  end

end
