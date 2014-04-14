class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|

      t.string :image
      t.string :name
      t.string :email
      t.string :phone
      t.string :fax
      t.string :description
      t.string :website

      t.timestamps
    end
  end
end
