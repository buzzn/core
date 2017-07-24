class AddImageToPerson < ActiveRecord::Migration
  def change
    add_column :persons, :image, :string
  end
end
