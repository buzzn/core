class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|

      t.string :name
      t.string :image
      t.string :name
      t.string :email
      t.string :phone

      t.integer :organizationable_id
      t.string  :organizationable_type

      t.timestamps
    end
  end
end
