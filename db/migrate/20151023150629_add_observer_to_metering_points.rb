class AddObserverToMeteringPoints < ActiveRecord::Migration
  def up
    add_column :metering_points, :observe, :boolean, default: false
    add_column :metering_points, :min_watt, :integer, default: 100
    add_column :metering_points, :max_watt, :integer, default: 5000
  end

  def down
    remove_column :metering_points, :observe
    remove_column :metering_points, :min_watt
    remove_column :metering_points, :max_watt
  end
end

