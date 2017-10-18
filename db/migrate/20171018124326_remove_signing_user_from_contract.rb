class RemoveSigningUserFromContract < ActiveRecord::Migration
  def change
    remove_column :contracts, :signing_user
  end
end
