class RemoveModeFromGroups < ActiveRecord::Migration
  def change
    remove_column :groups, :mode, :string
  end
end
