require 'buzzn/schemas/support/migration_visitor'
require 'buzzn/schemas/constraints/contract/tariff'

class CreateTariff < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::Contract::Tariff)

  def up
    SCHEMA.up(:tariffs, self)
    add_belongs_to :tariffs, :group, index: true, type: :uuid
    add_index :tariffs, [:begin_date, :group_id], unique: true
    add_foreign_key :tariffs, :groups, name: :fk_tariffs_group, null: false, on_delete: :cascade
  end

  def down
    remove_reference :tariffs, :localpool
    remove_index :tariffs, [:begin_date, :localpool_id]
    remove_foreign_key :tariffs, :groups, name: :fk_tariffs_group
    SCHEMA.down(:tariffs, self)
  end
end
