class CreateZipVnbs < ActiveRecord::Migration
  def change
    create_table :zip_vnbs do |t|
      t.string :zip
      t.string :place
      t.string :verbandsnummer
    end
    add_index :zip_vnbs, :zip
  end
end
