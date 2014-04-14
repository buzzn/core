class CreateDevicesMeteringPoints < ActiveRecord::Migration
  def change
    create_table :devices_metering_points do |t|
      t.integer :metering_point_id
      t.integer :device_id
    end
  end
end
