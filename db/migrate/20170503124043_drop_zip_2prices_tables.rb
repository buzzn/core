class DropZip2pricesTables < ActiveRecord::Migration
  def up
    drop_table :used_zip_sns
    drop_table :zip_vnbs
    drop_table :zip_kas
    drop_table :nne_vnbs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
