class CreateServicingContracts < ActiveRecord::Migration
  def change
    create_table :servicing_contracts do |t|
      t.string  :tariff
      t.string  :status
      t.string  :signing_user
      t.boolean :terms
      t.boolean :confirm_pricing_model
      t.boolean :power_of_attorney
      t.date    :commissioning
      t.date    :termination
      t.decimal :forecast_watt_hour_pa
      t.decimal :price_cents

      t.integer :organization_id
      t.integer :contracting_party_id
      t.integer :group_id

      t.timestamps
    end
    add_index :servicing_contracts, :organization_id
    add_index :servicing_contracts, :contracting_party_id
    add_index :servicing_contracts, :group_id
  end
end
