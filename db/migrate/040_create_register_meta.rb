require 'buzzn/schemas/constraints/register/meta'

class CreateRegisterMeta < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Register::Meta)

  def up
    SCHEMA.up(:register_meta, self)

    add_column :register_meta, :last_observed, :timestamp, null: true

    add_belongs_to :registers, :register_meta, index: true
    add_foreign_key :registers, :register_meta, name: :fk_registers_register_meta, column: :register_meta_id

    add_belongs_to :contracts, :register_meta, index: true, null: true
    add_foreign_key :contracts, :register_meta, name: :fk_contracts_register_meta, column: :register_meta_id

  end

end
