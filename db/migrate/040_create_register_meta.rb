require 'buzzn/schemas/constraints/register/meta'

class CreateRegisterMeta < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Register::Meta)

  def up
    SCHEMA.up(:register_meta, self)

    add_column :register_meta, :last_observed, :timestamp, null: true

    add_belongs_to :register_meta, :register, index: true
    add_foreign_key :register_meta, :registers, name: :fk_meta_register, on_delete: :cascade
  end

end
