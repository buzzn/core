class AddClosenessToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :closeness, :float
  end
end
