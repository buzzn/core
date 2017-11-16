require_relative '../support/active_record_sequel_migrations_adapter'

class CreateAccountPasswordHashesWithSequel < ActiveRecord::Migration

  include ActiveRecordSequelMigrationsAdapter

  def change
    run_sequel_migration(2)
  end
end
