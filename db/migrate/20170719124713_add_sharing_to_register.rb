class AddSharingToRegister < ActiveRecord::Migration
  def change
    add_column :registers, :share_with_group, :boolean
    add_column :registers, :share_publicly, :boolean

    change_column :registers, :share_with_group, :boolean, :default => true, :null => false
    change_column :registers, :share_publicly, :boolean, :default => false, :null => false
  end
end
