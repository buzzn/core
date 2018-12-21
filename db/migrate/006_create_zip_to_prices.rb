class CreateZipToPrices < ActiveRecord::Migration

  def change
    create_table :zip_to_prices do |t|
      t.string :zip, null: false
      t.float   :baseprice_euro_year_dt
      t.float   :unitprice_cents_kwh_dt
      t.float   :measurement_euro_year_dt
      # only et is mandatory as it is imported first!
      t.float   :baseprice_euro_year_et, null: false
      t.float   :unitprice_cents_kwh_et, null: false
      t.float   :measurement_euro_year_et, null: false
      t.float   :ka, null: false
      t.string  :community, null: false, limit: 512
      t.string  :dso, limit: 128, null: false
      t.string  :vnb, limit: 128, null: false
      t.boolean :updated, null: false
    end
    add_index :zip_to_prices, :zip
  end

end
