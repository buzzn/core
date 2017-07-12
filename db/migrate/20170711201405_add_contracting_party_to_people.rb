class AddContractingPartyToPeople < ActiveRecord::Migration
  def change
    add_column :people, :sales_tax_number, :integer
    add_column :people, :tax_rate, :float
    add_column :people, :tax_number, :integer
    add_column :people, :retailer, :boolean
    add_column :people, :provider_permission, :boolean
    add_column :people, :subject_to_tax, :boolean
    add_column :people, :mandate_reference, :string
    add_column :people, :creditor_id, :string
  end
end
