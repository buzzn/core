class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.string :blz
      t.string :description
      t.string :zip
      t.string :place
      t.string :name
      t.string :bic
    end
    add_index :banks, :blz, unique: true
    add_index :banks, :bic
  end
end
