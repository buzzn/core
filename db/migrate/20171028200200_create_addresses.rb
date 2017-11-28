require 'buzzn/schemas/constraints/address'

class CreateAddresses < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Address)

  def up
    SCHEMA.up(:addresses, self)
  end

  def down
    SCHEMA.down(:addresses, self)
  end
end
