class AddNotNullToTypeOnContracts < ActiveRecord::Migration
  def up
    change_column_null :contracts, :type, false
  end
  def down
    change_column_null :contracts, :type, true
  end
end
