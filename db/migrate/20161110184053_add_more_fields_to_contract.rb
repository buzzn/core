class AddMoreFieldsToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :renewable_energy_law_taxation, :string
    add_column :contracts, :third_party_billing_number, :string
    add_column :contracts, :third_party_renter_number, :string
    add_column :contracts, :first_master_uid, :string
    add_column :contracts, :second_master_uid, :string
    add_column :contracts, :metering_point_operator_name, :string
    add_column :contracts, :old_electricity_supplier_name, :string
    remove_column :contracts, :tariff
    remove_column :contracts, :price_cents
    remove_column :contracts, :price_currency
    remove_column :contracts, :running
    remove_column :contracts, :retailer
    remove_column :contracts, :price_cents_per_kwh
    remove_column :contracts, :price_cents_per_month
    remove_column :contracts, :discount_cents_per_month
  end
end
