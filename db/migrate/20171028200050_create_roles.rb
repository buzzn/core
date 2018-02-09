class CreateRoles < ActiveRecord::Migration

  def change
    create_enum :roles_name, *Role::ROLES_DB
    create_table :roles do |t|
      t.uuid :resource_id, null: true
      t.string :resource_type, null: true, limit: 32
    end
    add_column :roles, :name, :roles_name, null: true, index: true
  end

end
