class CreatePrivateGrids < ActiveRecord::Migration
  def change
    create_table :private_grids do |t|

      t.string  :name

      #gmap info
      t.integer :zoom,          :default => 16
      t.string  :address
      t.text    :polygons
      t.string  :polygon_encode
      t.float   :latitude
      t.float   :longitude
      t.boolean :gmaps

      t.timestamps
    end
  end
end
