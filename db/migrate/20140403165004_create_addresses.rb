class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string  :address
      t.string  :street
      t.string  :city
      t.string  :state
      t.integer :zip
      t.string  :country
      t.float   :longitude
      t.float   :latitude

      t.integer :addressable_id
      t.string  :addressable_type

      t.timestamps
    end
    add_index :addresses, [:addressable_id, :addressable_type], name: 'index_addressable'
  end
end
