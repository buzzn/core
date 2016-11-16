class RenameColumnMeteringPointIdtoRegisterIdOnContractingParties < ActiveRecord::Migration
  def change
    rename_column :contracting_parties, :metering_point_id, :register_id
  end
end
