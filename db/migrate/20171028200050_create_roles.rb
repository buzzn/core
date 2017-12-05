class CreateRoles < ActiveRecord::Migration

  def change
    create_table :roles do |t|
      t.string :name, null: false, length: 32
      t.uuid :resource_id, null: true
      t.uuid :resource_type, null: true, length: 32
    end
  end
end
