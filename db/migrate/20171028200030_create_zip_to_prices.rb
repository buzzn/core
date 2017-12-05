class CreateZipToPrices < ActiveRecord::Migration
  def change
    create_table :zip_to_prices, id: :uuid do |t|
      t.integer :zip, null: false
      t.float   :price_euro_year_dt, null: false
      t.float   :average_price_cents_kwh_dt, null: false
      t.float   :baseprice_euro_year_dt, null: false
      t.float   :unitprice_cents_kwh_dt, null: false
      t.float   :measurement_euro_year_dt, null: false
      t.float   :baseprice_euro_year_et, null: false
      t.float   :unitprice_cents_kwh_et, null: false
      t.float   :measurement_euro_year_et, null: false
      t.float   :ka, null: false
      t.string  :state, null: false, limit: 32
      t.string  :community, null: false, limit: 64
      t.integer :vdewid, null: false, limit: 8
      t.string  :dso, limit: 32, null: false
      t.boolean :updated, null: false
    end
    add_index :zip_to_prices, :zip
  end
end
