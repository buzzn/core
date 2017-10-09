class RenamePositionToSequenceNumberInMeter < ActiveRecord::Migration
  def change
    remove_index :meters, [:group_id, :position]
    rename_column :meters, :position, :sequence_number
    add_index :meters, [:group_id, :sequence_number], unique: true
  end
end
