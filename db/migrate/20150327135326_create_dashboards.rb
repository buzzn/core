class CreateDashboards < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'

    create_table :dashboards, id: :uuid do |t|
      t.string  :name
      t.string  :slug

      t.belongs_to :user, type: :uuid

      t.timestamps null: false
    end
    add_index :dashboards, :user_id
  end
end
