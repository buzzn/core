class CreatePrice < ActiveRecord::Migration
  def change
    create_table :prices, id: :uuid do |t|
      t.string :name, null: false
      t.integer :baseprice_cents_per_month, null: false
      t.float :energyprice_cents_per_kilowatt_hour, null: false
      t.date :begin_date, null: false

      t.belongs_to :localpool, type: :uuid

      t.timestamps null: false
    end
    add_index :prices, [:begin_date, :localpool_id], unique: true
  end
end
