class RolesEnum < ActiveRecord::Migration
  def change
    create_enum :role_names, *Role::ROLES_DB

    rename_column :roles, :name, :n
    add_column :roles, :name, :role_names, null: true, index: true

    Role.all.each do |a|
      case a.n
      when 'admin'
        a.buzzn_operator!
      when 'manager'
        a.group_admin!
      when 'self'
        a.self!
      when 'contract'
        a.contract!
      when 'member'
        a.group_member!
      else
        raise "unknown role #{a.n}"
      end
    end

    change_column_null :roles, :name, false
    remove_column :roles, :n

    Role.reset_column_information
  end
end
