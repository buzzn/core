class CreateIlns < ActiveRecord::Migration
  def change
    create_table :ilns do |t|
      t.string :bdew
      t.string :eic
      t.string :vnb
      t.date :valid_begin
      t.date :valid_end

      t.integer :organization_id

      t.timestamps
    end
    add_index :ilns, :organization_id
  end
end
