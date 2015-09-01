class CreateMeteringPointUserRequests < ActiveRecord::Migration
  def change
    create_table :metering_point_user_requests, id: :uuid do |t|
      t.belongs_to :user, type: :uuid
      t.belongs_to :metering_point, type: :uuid
      t.string :mode
      t.string :status

      t.timestamps null: false
    end
    add_index :metering_point_user_requests, :user_id
    add_index :metering_point_user_requests, :metering_point_id
    add_index :metering_point_user_requests, :mode
  end
end
