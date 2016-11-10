class AddFieldsToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :market_place_id, :string
    add_column :organizations, :represented_by, :string
  end
end
