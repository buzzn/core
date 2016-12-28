class AddTypeToMeters < ActiveRecord::Migration
  def change
    add_column :meters, :type, :string, null: false
  end
end
