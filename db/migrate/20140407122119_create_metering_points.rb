class CreateMeteringPoints < ActiveRecord::Migration
  def change
    create_table :metering_points do |t|

      t.string  :slug
      t.string  :uid
      t.string  :image
      t.string  :address_addition

      t.string  :voltage_level
      t.date    :regular_reeding
      t.string  :regular_interval

      t.string  :ancestry
      t.integer :contract_id
      t.integer :group_id

      t.timestamps
    end
    add_index :metering_points, :ancestry
    add_index :metering_points, :contract_id
    add_index :metering_points, :group_id
  end
end
