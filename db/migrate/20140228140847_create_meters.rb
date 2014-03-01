class CreateMeters < ActiveRecord::Migration
  def change
    create_table :meters do |t|
      t.string  :name
      t.integer :uid
      t.boolean :private
      t.string  :type

      t.integer :user_id

      t.timestamps
    end
  end
end
