class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string  :slug
      t.string  :name
      t.boolean :private
      t.string  :type

      t.integer :meter_id
      t.integer :user_id

      t.timestamps
    end
  end
end
