class CreateDashboards < ActiveRecord::Migration
  def change
    create_table :dashboards do |t|
      t.integer :user_id
      t.string  :slug

      t.timestamps null: false
    end
    add_index :dashboards, :user_id
  end
end
