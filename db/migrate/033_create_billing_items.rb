require 'buzzn/schemas/constraints/billing_cycle'

class CreateBillingItems < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::BillingItem)

  def up
    SCHEMA.up(:billing_items, self)
    add_belongs_to :billing_items, :billing, references: :billing, index: true, null: false
    add_foreign_key :billing_items, :billings, name: :fk_billing_items_billing, column: :billing_id

    add_belongs_to :billing_items, :begin_reading, references: :reading, index: true #, null: false
    # add_foreign_key :billing_items, :readings, name: :fk_billing_items_begin_reading, column: :begin_reading_id

    add_belongs_to :billing_items, :end_reading, references: :reading, index: true #, null: false
    # add_foreign_key :billing_items, :readings, name: :fk_billing_items_end_reading, column: :end_reading_id

    add_belongs_to :billing_items, :tariff, references: :tariff, index: true #, null: false
    # add_foreign_key :billing_items, :tariffs, name: :fk_billing_items_tariff, column: :tariff_id
  end

  def down
    remove_foreign_key :billing_items, :billings, name: :fk_billing_items_localpool, column: :localpool_id
    remove_belongs_to :billing_items, :billing, references: :billing, index: true, null: false
    SCHEMA.down(:billing_items, self)
  end

end
