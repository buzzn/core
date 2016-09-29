class CreateZipKas < ActiveRecord::Migration
  def change
    create_table :zip_kas, id: false do |t|
      t.string :zip, null: false
      t.float :ka
    end
    add_index :zip_kas, :zip, unique: true
  end
end
