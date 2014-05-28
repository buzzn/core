class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|

      t.string  :name

      #gmap info
      t.integer :zoom,          :default => 16
      t.string  :address
      t.text    :polygons
      t.string  :polygon_encode
      t.float   :latitude
      t.float   :longitude
      t.boolean :gmaps

      t.integer :group_id

      t.timestamps
    end
    add_index :areas, :group_id
  end
end
