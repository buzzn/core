class RenameColumnMeteringPointIdtoRegisterIdOnFormulaParts < ActiveRecord::Migration
  def change
    rename_column :formula_parts, :metering_point_id, :register_id
  end
end
