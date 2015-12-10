class AddExternalToMeteringPoint < ActiveRecord::Migration
  def up
    add_column :metering_points, :external, :boolean, default: false
  end

  def down
    remove_column :metering_points, :external
  end
end
