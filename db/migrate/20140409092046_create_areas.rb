class CreateAreas < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :areas, id: :uuid do |t|

      t.string  :name

      #gmap info
      t.integer :zoom,          :default => 16
      t.string  :address
      t.text    :polygons
      t.string  :polygon_encode
      t.float   :latitude
      t.float   :longitude
      t.boolean :gmaps

      t.belongs_to :group, type: :uuid

      t.timestamps
    end
    add_index :areas, :group_id
  end
end
