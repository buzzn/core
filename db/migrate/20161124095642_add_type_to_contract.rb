class AddTypeToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :type, :string
  end
end
