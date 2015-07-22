class ChangeDoorkeeperResourceOwnerId < ActiveRecord::Migration
  def change
    change_column :oauth_access_grants, :resource_owner_id, :string
    change_column :oauth_access_tokens, :resource_owner_id, :string
  end
end
