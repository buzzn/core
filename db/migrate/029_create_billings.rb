require 'buzzn/schemas/constraints/billing'

class CreateBillings < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Billing)

  def up
    SCHEMA.up(:billings, self)

    add_belongs_to :billings, :billing_cycle, index: true, null: true
    add_belongs_to :billings, :contract, references: :contract, index: true, null: false

    add_foreign_key :billings, :billing_cycles, name: :fk_billings_billing_cycles
    add_foreign_key :billings, :contracts, name: :fk_billings_contracts, column: :contract_id

    add_index :billings, [:billing_cycle_id, :status]
    add_index :billings, [:invoice_number, :invoice_number_addition], unique: true
  end

  def down
    SCHEMA.down(:billings, self)
  end

end
