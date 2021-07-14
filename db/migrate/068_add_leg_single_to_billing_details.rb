class AddLegSingleToBillingDetails < ActiveRecord::Migration

  def up
    add_column :billing_details, :leg_single, :boolean, :default => false
  end

  def down
    remove_column :billing_details, :leg_single
  end

end 