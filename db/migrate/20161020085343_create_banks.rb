class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.string :blz, null: false, size: 32
      t.string :description, null: false, size: 128
      t.string :zip, null: false, size: 16
      t.string :place, null: false, size: 64
      t.string :name, null: false, size: 64
      t.string :bic, null: false, size: 16
    end
    add_index :banks, :blz, unique: true
    add_index :banks, :bic
  end
end
