require 'buzzn/schemas/constraints/billing_cycle'

class CreateBillingCycles < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::BillingCycle)

  def up
    SCHEMA.up(:billing_cycles, self)

    add_belongs_to :billing_cycles, :localpool, references: :group, type: :uuid, index: true, null: false

    add_foreign_key :billing_cycles, :groups, name: :fk_billing_cycles_localpools, column: :localpool_id
  end

  def down
    remove_foreign_key :billing_cycles, :groups, name: :fk_billing_cycles_localpools, column: :localpool_id
    remove_belongs_to :billing_cycles, :localpool, references: :group, type: :uuid, index: true, null: false
    SCHEMA.down(:billing_cycles, self)
  end
end
