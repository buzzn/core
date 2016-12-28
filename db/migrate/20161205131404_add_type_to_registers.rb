class AddTypeToRegisters < ActiveRecord::Migration
  def change
    add_column :registers, :type, :string, null: false
  end
end
