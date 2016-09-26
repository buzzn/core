class AddFieldsToBankAccount < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :mandate, :boolean
  end
end
