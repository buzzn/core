class AddAccessTokenToContract < ActiveRecord::Migration
  def up
    add_column :contracts, :encrypted_external_access_token, :string
    add_column :contracts, :encrypted_external_access_token_secret, :string
  end

  def down
    remove_column :contracts, :encrypted_external_access_token, :string
    remove_column :contracts, :encrypted_external_access_token_secret, :string
  end
end
