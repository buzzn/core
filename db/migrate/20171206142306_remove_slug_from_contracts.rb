class RemoveSlugFromContracts < ActiveRecord::Migration
  def change
    remove_column :contracts, :slug, :string
  end
end
