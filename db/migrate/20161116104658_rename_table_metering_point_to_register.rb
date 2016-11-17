class RenameTableMeteringPointToRegister < ActiveRecord::Migration
  def change
    rename_index :metering_points, "index_metering_points_on_contract_id", "index_registers_on_contract_id"
    rename_index :metering_points, "index_metering_points_on_group_id",    "index_registers_on_group_id"
    rename_index :metering_points, "index_metering_points_on_meter_id",    "index_registers_on_meter_id"
    rename_index :metering_points, "index_metering_points_on_readable",    "index_registers_on_readable"
    rename_table :metering_points, :registers
  end
end
