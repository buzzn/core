class ChangeRegisterFieldType < ActiveRecord::Migration
  def up
    remove_column :registers, :low_load_ability, :string
    add_column :registers, :low_load_ability, :boolean
  end

  def down
    add_column :registers, :low_load_ability, :string
    remove_column :registers, :low_load_ability, :boolean
  end
end
