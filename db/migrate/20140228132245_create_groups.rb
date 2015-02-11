class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string  :slug
      t.string  :name
      t.string  :logo
      t.string  :website
      t.string  :image
      t.string  :mode, :default => ""
      t.boolean :private, default: false
      t.text    :description

      t.timestamps
    end
  end
end
