require 'buzzn/schemas/constraints/billing_cycle'

class CreateBillingBricks < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::BillingBrick)

  def up
    SCHEMA.up(:billing_bricks, self)
    change_column_default :billing_bricks, :status, :open
    add_belongs_to :billing_bricks, :billing, references: :billing, index: true, null: false
    # add_foreign_key :billing_bricks, :billing, name: :fk_billing_bricks_billing, column: :billing_id
  end

  def down
    # remove_foreign_key :billing_bricks, :groups, name: :fk_billing_bricks_localpool, column: :localpool_id
    remove_belongs_to :billing_bricks, :billing, references: :billing, index: true, null: false
    SCHEMA.down(:billing_bricks, self)
  end

end
