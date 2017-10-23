class RemoveStatusFromContract < ActiveRecord::Migration
  def change
    remove_column :contracts, :status
    drop_enum :contract_status
  end
end
