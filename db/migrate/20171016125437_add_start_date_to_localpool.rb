class AddStartDateToLocalpool < ActiveRecord::Migration
  def change
    add_column :groups, :start_date, :date, null: true
  end
end
