class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :slug
      t.string :image
      t.string :name
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
