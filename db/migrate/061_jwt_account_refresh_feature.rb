require_relative '../support/active_record_sequel_migrations_adapter'

class JwtAccountRefreshFeature < ActiveRecord::Migration

  include ActiveRecordSequelMigrationsAdapter

  def change
    run_sequel_migration(3)
  end

end
