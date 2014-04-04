class CreateMeters < ActiveRecord::Migration
  def change
    create_table :meters do |t|
      t.string  :slug

      t.string  :name
      t.decimal :uid
      t.string  :manufacturer

      t.integer :contract_id

      t.timestamps
    end
    add_index :meters, :contract_id
  end
end
