class AddContractingPartyToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :sales_tax_number, :integer
    add_column :organizations, :tax_rate, :float
    add_column :organizations, :tax_number, :integer
    add_column :organizations, :retailer, :boolean
    add_column :organizations, :provider_permission, :boolean
    add_column :organizations, :subject_to_tax, :boolean
    add_column :organizations, :mandate_reference, :string
    add_column :organizations, :creditor_id, :string
  end
end
