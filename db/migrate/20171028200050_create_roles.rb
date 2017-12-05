class CreateRoles < ActiveRecord::Migration

  def change
    create_table :roles do |t|
      t.string :name, null: false, limit: 64
      t.uuid :resource_id, null: true
      t.string :resource_type, null: true, limit: 32
    end
  end
end
