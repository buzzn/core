require 'buzzn/schemas/support/migration_visitor'
require 'buzzn/schemas/constraints/price'

class CreatePrices < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::Price)

  def up
    SCHEMA.up(:prices, self)
    add_belongs_to :prices, :localpool, index: true, type: :uuid
    add_index :prices, [:begin_date, :localpool_id], unique: true
    add_foreign_key :prices, :groups, name: :fk_prices_localpool, null: false, column: :localpool_id
  end

  def down
    remove_reference :prices, :localpool
    remove_index :prices, [:begin_date, :localpool_id]
    remove_foreign_key :prices, :groups, name: :fk_prices_localpool
    SCHEMA.down(:prices, self)
  end
end
