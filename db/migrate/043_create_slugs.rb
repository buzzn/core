require_relative '../support/active_record_sequel_migrations_adapter'

class CreateSlugs < ActiveRecord::Migration

  include ActiveRecordSequelMigrationsAdapter

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Slug)
  def up
    SCHEMA.up(:slugs, self)
    add_index :slugs, [:namespace, :basename], unique: true
  end

  def down
    SCHEMA.up(:slugs, self)
  end

end
