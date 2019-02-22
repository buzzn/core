class RemoveValueFromReading < ActiveRecord::Migration

  def up
    remove_column :readings, :value
  end

  def down
    add_column :readings, :value, :bigint
  end

end
