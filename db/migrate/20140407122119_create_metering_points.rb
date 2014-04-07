class CreateMeteringPoints < ActiveRecord::Migration
  def change
    create_table :metering_points do |t|
      t.string :uid

      t.timestamps
    end
  end
end
