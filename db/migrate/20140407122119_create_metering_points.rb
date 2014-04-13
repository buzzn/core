class CreateMeteringPoints < ActiveRecord::Migration
  def change
    create_table :metering_points do |t|
      t.string  :uid
      t.integer :position
      t.string  :address_addition
      t.string  :mode

      t.integer :location_id
      t.integer :contract_id

      t.timestamps
    end
  end
end
