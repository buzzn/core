require 'buzzn/schemas/support/migration_visitor'
require 'buzzn/schemas/constraints/contract/tariff'

class CreateTariff < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Contract::Tariff)

  def up
    SCHEMA.up(:tariffs, self)
    add_belongs_to :tariffs, :group, index: true, null: false, type: :uuid
    add_foreign_key :tariffs, :groups, name: :fk_tariffs_group, on_delete: :cascade
  end

  def down
    remove_reference :tariffs, :localpool
    remove_foreign_key :tariffs, :groups, name: :fk_tariffs_group
    SCHEMA.down(:tariffs, self)
  end
end
