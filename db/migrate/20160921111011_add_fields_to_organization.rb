class AddFieldsToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :authority, :boolean
    add_column :organizations, :provider_permission, :boolean
    add_column :organizations, :retailer, :boolean
  end
end
