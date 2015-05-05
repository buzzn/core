class CreateAddresses < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :addresses, id: :uuid do |t|
      t.string  :slug
      t.string  :address
      t.string  :street_name
      t.string  :street_number
      t.string  :city
      t.string  :state
      t.integer :zip
      t.string  :country
      t.float   :longitude
      t.float   :latitude
      t.string  :time_zone
      t.string  :readable

      t.belongs_to :addressable, type: :uuid
      t.string  :addressable_type

      t.timestamps
    end
    add_index :addresses, :slug, :unique => true
    add_index :addresses, [:addressable_id, :addressable_type], name: 'index_addressable'
    add_index :addresses, :readable
  end
end
