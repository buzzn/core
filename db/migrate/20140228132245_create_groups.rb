class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string  :slug
      t.string  :name
      t.boolean :private, default: false
      t.text    :description

      t.timestamps
    end
  end
end
