class CreateMeters < ActiveRecord::Migration
  def change
    create_table :meters do |t|

      t.string  :uid
      t.string  :manufacturer

      t.integer :metering_point_id

      t.timestamps
    end
    add_index :meters, :metering_point_id
  end
end
