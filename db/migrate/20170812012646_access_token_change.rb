class AccessTokenChange < ActiveRecord::Migration
  def change
    Doorkeeper::AccessToken.delete_all
    remove_column :oauth_access_tokens, :resource_owner_id
    add_column :oauth_access_tokens, :resource_owner_id, :integer
  end
end
