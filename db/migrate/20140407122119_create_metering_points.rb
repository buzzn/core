class CreateMeteringPoints < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :metering_points, id: :uuid do |t|
      t.string  :slug
      t.string  :uid
      t.string  :mode
      t.string  :name
      t.string  :image
      t.string  :voltage_level
      t.date    :regular_reeding
      t.string  :regular_interval
      t.boolean :virtual, default: false
      t.boolean :is_dashboard_metering_point, default: false
      t.string  :readable

      t.belongs_to :meter, type: :uuid
      t.belongs_to :contract, type: :uuid
      t.belongs_to :group, type: :uuid

      t.timestamps
    end
    add_index :metering_points, :slug, :unique => true
    add_index :metering_points, :meter_id
    add_index :metering_points, :contract_id
    add_index :metering_points, :group_id
    add_index :metering_points, :readable
  end
end
