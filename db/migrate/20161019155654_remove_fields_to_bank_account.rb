class RemoveFieldsToBankAccount < ActiveRecord::Migration
  def change
    remove_column :bank_accounts, :mandate
  end
end
