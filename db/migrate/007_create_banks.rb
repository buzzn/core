class CreateBanks < ActiveRecord::Migration

  def change
    create_table :banks do |t|
      t.string :blz, null: false, limit: 32
      t.string :description, null: false, limit: 128
      t.string :zip, null: false, limit: 16
      t.string :place, null: false, limit: 64
      t.string :name, null: false, limit: 64
      t.string :bic, null: false, limit: 16
    end
    add_index :banks, :blz, unique: true
    add_index :banks, :bic
  end

end
