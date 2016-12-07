class RemoveModeFromContract < ActiveRecord::Migration
  def change
    remove_column :contracts, :mode, :string
  end
end
