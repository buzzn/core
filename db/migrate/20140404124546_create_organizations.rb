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
    add_index :organizations, [:organizationable_id, :organizationable_type], name: 'index_organizationable'
  end
end
