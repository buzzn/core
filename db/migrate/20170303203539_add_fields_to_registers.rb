class AddFieldsToRegisters < ActiveRecord::Migration
  def change
    add_column :registers, :obis, :string
    add_column :registers, :label, :string
    add_column :registers, :low_load_ability, :string
    add_column :registers, :digits_before_comma, :integer
    add_column :registers, :decimal_digits, :integer
    remove_column :registers, :voltage_level, :string
    remove_column :registers, :regular_interval, :string
    remove_column :registers, :contract_id, :string
    remove_column :registers, :external, :boolean
  end
end
