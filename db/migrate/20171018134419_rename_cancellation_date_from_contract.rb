class RenameCancellationDateFromContract < ActiveRecord::Migration
  def change
    rename_column :contracts, :cancellation_date, :termination_date
  end
end
