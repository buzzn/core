class AddLastObservedTimestampToMeteringPoints < ActiveRecord::Migration
  def up
    add_column :metering_points, :last_observed_timestamp, :timestamp
    add_column :metering_points, :observe_offline, :boolean, default: false
  end

  def down
    remove_column :metering_points, :last_observed_timestamp
    remove_column :metering_points, :observe_offline
  end
end
