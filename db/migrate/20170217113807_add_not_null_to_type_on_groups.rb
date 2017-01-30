class AddNotNullToTypeOnGroups < ActiveRecord::Migration
  def up
    change_column_null :groups, :type, false
  end
  def down
    change_column_null :groups, :type, true
  end
end
