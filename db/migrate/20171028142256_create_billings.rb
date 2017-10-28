require 'buzzn/schemas/constraints/billing'

class CreateBillings < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::Billing)

  def up
    SCHEMA.up(:billings, self)

    add_belongs_to :billings, :start_reading, references: :readings, type: :uuid#, null: false
    add_belongs_to :billings, :end_reading, references: :readings, type: :uuid#, null: false
    add_belongs_to :billings, :device_change_reading_1, references: :readings, type: :uuid, null: true
    add_belongs_to :billings, :device_change_reading_2, references: :readings, type: :uuid, null: true
    add_belongs_to :billings, :billing_cycle, type: :uuid, index: true, null: true
    add_belongs_to :billings, :localpool_power_taker_contract, references: :contract, type: :uuid, index: true, null: false

    add_foreign_key :billings, :readings, name: :fk_billings_start_reading, column: :start_reading_id
    add_foreign_key :billings, :readings, name: :fk_billings_end_reading, null: false, column: :end_reading_id
    add_foreign_key :billings, :readings, name: :fk_billings_device_change_1, null: true, column: :device_change_reading_1_id
    add_foreign_key :billings, :readings, name: :fk_billings_device_change_2, null: true, column: :device_change_reading_2_id
    add_foreign_key :billings, :billing_cycles, name: :fk_billings_billing_cycles, null: false
    add_foreign_key :billings, :contracts, name: :fk_billings_contracs, null: false, column: :localpool_power_taker_contract_id

    add_index :billings, [:billing_cycle_id, :status]
  end

  def down
    SCHEMA.down(:billings, self)
  end
end
