class RenameColumnMeteringPointIdtoRegisterIdOnContracts < ActiveRecord::Migration
  def change
    rename_column :contracts, :metering_point_id, :register_id
  end
end
