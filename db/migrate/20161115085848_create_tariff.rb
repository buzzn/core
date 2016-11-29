class CreateTariff < ActiveRecord::Migration
  def change
    create_table :tariffs do |t|
      t.string :name, null: false
      t.date :begin_date, null: false
      t.date :end_date
      t.integer :energyprice_cents_per_kwh, null: false
      t.integer :baseprice_cents_per_month, null: false
      t.belongs_to :contract, index: true, foreign_key: true, type: :uuid, null: false
    end
  end
end
