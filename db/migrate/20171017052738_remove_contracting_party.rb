class RemoveContractingParty < ActiveRecord::Migration
  def change
    remove_column :persons, :sales_tax_number
    remove_column :persons, :tax_rate
    remove_column :persons, :tax_number
    remove_column :persons, :retailer
    remove_column :persons, :provider_permission
    remove_column :persons, :subject_to_tax
    remove_column :persons, :mandate_reference
    remove_column :persons, :creditor_id
    remove_column :organizations, :sales_tax_number
    remove_column :organizations, :tax_rate
    remove_column :organizations, :tax_number
    remove_column :organizations, :retailer
    remove_column :organizations, :provider_permission
    remove_column :organizations, :subject_to_tax
    remove_column :organizations, :mandate_reference
    remove_column :organizations, :creditor_id

    add_column :contracts, :mandate_reference, :string
  end
end
