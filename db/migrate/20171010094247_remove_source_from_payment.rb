class RemoveSourceFromPayment < ActiveRecord::Migration
  def change
    remove_column :payments, :source
  end
end
