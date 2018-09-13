require 'buzzn/schemas/constraints/register/meta_option'

class CreateRegisterMetaOptions < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Register::MetaOption)

  def up
    SCHEMA.up(:register_meta_options, self)

    add_belongs_to :contracts, :register_meta_option, index: true, null: true
    add_foreign_key :contracts, :register_meta_options, name: :fk_contracts_register_meta_option, column: :register_meta_option_id
  end

  def down
    SCHEMA.down(:register_meta_options, self)
  end

end
