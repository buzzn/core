class RemoveFirstSecondMasterUidFromContract < ActiveRecord::Migration
  def change
    remove_column :contracts, :first_master_uid
    remove_column :contracts, :second_master_uid
  end
end
