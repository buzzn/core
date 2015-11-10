class AddChartTimestampToComments < ActiveRecord::Migration
  def up
    add_column :comments, :chart_resolution, :string
    add_column :comments, :chart_timestamp, :timestamp
  end

  def down
    remove_column :comments, :chart_timestamp
    remove_column :comments, :chart_resolution
  end
end
