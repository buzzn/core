class AddPositionToMeter < ActiveRecord::Migration
  def change
    add_column :meters, :position, :integer, null: true
    add_column :meters, :group_id, :uuid, null: true
    add_foreign_key :meters, :groups
    add_index :meters, [:group_id, :position], unique: true
  end
end
