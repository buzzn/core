class DropMeterRegisterFormulaPart < ActiveRecord::Migration
  def change
    drop_table :formula_parts
  end
end
