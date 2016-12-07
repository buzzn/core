class AddCancellationDateToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :cancellation_date, :date
  end
end
