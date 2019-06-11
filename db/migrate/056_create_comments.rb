require 'buzzn/schemas/constraints/comment'

class CreateComments < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Comment)

  def up
    SCHEMA.up(:comments, self)
  end

  def down
    SCHEMA.down(:comments, self)
  end

end
