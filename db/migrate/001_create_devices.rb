require 'buzzn/schemas/constraints/device'

class CreateDevices < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Device)

  def up
    SCHEMA.up(:devices, self)
  end

  def down
    SCHEMA.down(:devices, self)
  end

end
