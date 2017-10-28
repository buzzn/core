class DropBilling < ActiveRecord::Migration
  def change
    drop_table :billings
  end
end
