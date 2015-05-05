class CreateMeteringPointUsers < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :metering_point_users, id: :uuid do |t|

      t.integer :usage, default: 100

      t.belongs_to :user, type: :uuid
      t.belongs_to :metering_point, type: :uuid

      t.timestamps
    end
    add_index :metering_point_users, :metering_point_id
    add_index :metering_point_users, :user_id
  end
end
