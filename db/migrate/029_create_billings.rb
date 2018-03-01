require 'buzzn/schemas/constraints/billing'

class CreateBillings < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Billing)

  def up
    SCHEMA.up(:billings, self)

    add_belongs_to :billings, :billing_cycle, index: true, null: true
    add_belongs_to :billings, :localpool_power_taker_contract, references: :contract, index: true, null: false

    add_foreign_key :billings, :billing_cycles, name: :fk_billings_billing_cycles
    add_foreign_key :billings, :contracts, name: :fk_billings_contracts, column: :localpool_power_taker_contract_id

    add_index :billings, [:billing_cycle_id, :status]
  end

  def down
    SCHEMA.down(:billings, self)
  end

end
