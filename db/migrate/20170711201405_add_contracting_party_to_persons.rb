class AddContractingPartyToPersons < ActiveRecord::Migration
  def change
    add_column :persons, :sales_tax_number, :integer
    add_column :persons, :tax_rate, :float
    add_column :persons, :tax_number, :integer
    add_column :persons, :retailer, :boolean
    add_column :persons, :provider_permission, :boolean
    add_column :persons, :subject_to_tax, :boolean
    add_column :persons, :mandate_reference, :string
    add_column :persons, :creditor_id, :string
  end
end
