class CreateDashboards < ActiveRecord::Migration
  def change
    create_table :dashboards do |t|
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :dashboards, :user_id

    create_table :dashboards_metering_points, id: false do |t|
      t.belongs_to :dashboard, index: true
      t.belongs_to :metering_point, index: true
    end
  end
end
