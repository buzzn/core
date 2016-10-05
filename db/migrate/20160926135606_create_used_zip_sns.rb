class CreateUsedZipSns < ActiveRecord::Migration
  def change
    create_table :used_zip_sns do |t|
      t.string :zip
      t.integer :kwh
      t.float :price
      t.datetime :created_at
    end
  end
end
