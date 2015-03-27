class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string  :slug
      t.string  :name
      t.string  :logo
      t.string  :website
      t.string  :image
      t.string  :mode, :default => ""
      t.string  :secret_level
      t.text    :description

      t.timestamps
    end
    add_index :groups, :slug, :unique => true
    add_index :groups, :secret_level
  end
end
