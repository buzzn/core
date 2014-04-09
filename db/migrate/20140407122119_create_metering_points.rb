class CreateMeteringPoints < ActiveRecord::Migration
  def change
    create_table :metering_points do |t|
      t.string :uid
      t.string :address_addition

      t.integer :location_id

      t.timestamps
    end
  end
end
