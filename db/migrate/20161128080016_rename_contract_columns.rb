class RenameContractColumns < ActiveRecord::Migration
  def change
    rename_column :contracts, :signing_user, :original_signing_user
    rename_column :contracts, :group_id, :localpool_id
    rename_column :contracts, :commissioning, :signing_date
    rename_column :contracts, :beginning, :begin_date
    rename_column :contracts, :termination, :end_date
    rename_column :contracts, :terms, :terms_accepted
    rename_column :contracts, :forecast_watt_hour_pa, :forecast_kwh_pa
  end
end
