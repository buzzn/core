class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|

      t.string :slug
      t.string :image
      t.string :name
      t.string :email
      t.string :phone
      t.string :fax
      t.string :description
      t.string :website
      t.string :mode

      t.timestamps
    end
    add_index :organizations, :slug, :unique => true
  end
end
