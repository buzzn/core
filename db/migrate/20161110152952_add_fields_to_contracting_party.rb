class AddFieldsToContractingParty < ActiveRecord::Migration
  def change
    add_column :contracting_parties, :retailer, :boolean
    add_column :contracting_parties, :provider_permission, :boolean
    add_column :contracting_parties, :subject_to_tax, :boolean
    add_column :contracting_parties, :mandate_reference, :string
    add_column :contracting_parties, :creditor_id, :string
    remove_column :contracting_parties, :metering_point_id
  end
end
