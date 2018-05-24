require 'buzzn/schemas/constraints/template'

class CreateTemplates < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Template)

  def up
    SCHEMA.up(:templates, self)
  end

  def down
    SCHEMA.down(:templates, self)
  end

end
