class DropMeterRegisterFormulaPart < ActiveRecord::Migration
  def change
    drop_table :formula_parts
    drop_table :registers
    #drop_table :meters
  end
end
