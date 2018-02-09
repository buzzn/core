class DropCoreTables < ActiveRecord::Migration

  def change
    add_column :devices, :register_id, :integer, null: true
  end

end
