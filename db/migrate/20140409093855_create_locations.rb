class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|

      t.string  :name
      t.string  :slug
      t.boolean :new_habitation, default: false
      t.date    :inhabited_since
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
