class RemoveGridFeedingAndConsumptionRegistersFromGroup < ActiveRecord::Migration

  def change
    remove_column :groups, :grid_feeding_register_id, :uuid
    remove_column :groups, :grid_consumption_register_id, :uuid
  end

end
