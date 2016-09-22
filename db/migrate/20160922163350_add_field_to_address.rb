class AddFieldToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :addition, :string
  end
end
