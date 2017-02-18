class AddContractingPartyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sales_tax_number, :integer
    add_column :users, :tax_rate, :float
    add_column :users, :tax_number, :integer
    add_column :users, :retailer, :boolean
    add_column :users, :provider_permission, :boolean
    add_column :users, :subject_to_tax, :boolean
    add_column :users, :mandate_reference, :string
    add_column :users, :creditor_id, :string
  end
end
