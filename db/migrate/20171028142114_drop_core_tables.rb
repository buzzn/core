class DropCoreTables < ActiveRecord::Migration
  def change
    add_column :devices, :register_id, :uuid, null: true
  end
end
