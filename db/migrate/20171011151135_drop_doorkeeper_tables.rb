class DropDoorkeeperTables < ActiveRecord::Migration
  def change
    drop_table :oauth_access_grants
    drop_table :oauth_access_tokens
    drop_table :oauth_applications
  end
end
