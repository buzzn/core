class AddPurposeToDocuments < ActiveRecord::Migration

  def up
    add_column :documents, :purpose, :string, null: true, limit: 32
  end

  def down
    remove_column :documents, :purpose
  end

end
