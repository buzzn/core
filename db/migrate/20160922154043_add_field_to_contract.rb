class AddFieldToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :retailer, :boolean
  end
end
