class AddLegSingleToBillingDetail < ActiveRecord::Migration

    def up
      add_column :billing_details, :leg_single, :boolean
    end
  
    def down
      remove_column :billing_details, :leg_single
    end
  
end