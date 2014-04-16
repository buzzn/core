class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|

      t.string  :status
      t.decimal :price_cents, precision: 16, default: 0
      t.string  :signing_user
      t.boolean :terms
      t.boolean :confirm_pricing_model
      t.boolean :power_of_attorney
      t.date    :commissioning
      t.date    :termination
      t.decimal :forecast_wa_pa
      t.string  :mode

      t.integer :contracting_party_id

      t.timestamps
    end
    add_index :contracts, :contracting_party_id
  end
end
