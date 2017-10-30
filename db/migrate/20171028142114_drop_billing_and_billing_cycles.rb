class DropBillingAndBillingCycles < ActiveRecord::Migration
  def change
    drop_table :billings
    drop_table :billing_cycles
  end
end
