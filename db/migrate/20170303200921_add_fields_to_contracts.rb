class AddFieldsToContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :energy_consumption_before_kwh_pa, :string
    add_column :contracts, :down_payment_before_cents_per_month, :string
    remove_column :contracts, :username, :string
    remove_column :contracts, :encrypted_password, :string
    remove_column :contracts, :valid_credentials, :boolean
  end
end
