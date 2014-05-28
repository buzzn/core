class CreateMeteringPointUsers < ActiveRecord::Migration
  def change
    create_table :metering_point_users do |t|

      t.integer :usage, default: 100

      t.integer :user_id
      t.integer :metering_point_id

      t.timestamps
    end
  end
end
