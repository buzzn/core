require_relative '../support/active_record_sequel_migrations_adapter'

class CreateAccountsWithSequel < ActiveRecord::Migration

  include ActiveRecordSequelMigrationsAdapter

  def up
    run_sequel_migration(1)
  end
end
