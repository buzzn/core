class CreateGroupsOld < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :groups, id: :uuid do |t|
      t.string  :slug
      t.string  :name
      t.string  :logo
      t.string  :website
      t.string  :image
      t.string  :mode, :default => ""
      t.string  :readable
      t.text    :description

      t.timestamps
    end
    add_index :groups, :slug, :unique => true
    add_index :groups, :readable
  end
end
