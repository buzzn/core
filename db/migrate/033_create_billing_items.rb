require 'buzzn/schemas/constraints/billing_cycle'

class CreateBillingBricks < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::BillingBrick)

  def up
    SCHEMA.up(:billing_bricks, self)
    add_belongs_to :billing_bricks, :billing, references: :billing, index: true, null: false
    add_foreign_key :billing_bricks, :billings, name: :fk_billing_bricks_billing, column: :billing_id

    add_belongs_to :billing_bricks, :begin_reading, references: :reading, index: true #, null: false
    # add_foreign_key :billing_bricks, :readings, name: :fk_billing_bricks_begin_reading, column: :begin_reading_id

    add_belongs_to :billing_bricks, :end_reading, references: :reading, index: true #, null: false
    # add_foreign_key :billing_bricks, :readings, name: :fk_billing_bricks_end_reading, column: :end_reading_id

    add_belongs_to :billing_bricks, :tariff, references: :tariff, index: true #, null: false
    # add_foreign_key :billing_bricks, :tariffs, name: :fk_billing_bricks_tariff, column: :tariff_id
  end

  def down
    remove_foreign_key :billing_bricks, :billings, name: :fk_billing_bricks_localpool, column: :localpool_id
    remove_belongs_to :billing_bricks, :billing, references: :billing, index: true, null: false
    SCHEMA.down(:billing_bricks, self)
  end

end
