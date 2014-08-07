class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string :image
      t.text :description

      t.integer :position

      t.integer :assetable_id
      t.string  :assetable_type

      t.timestamps
    end
    add_index :assets, [:assetable_id, :assetable_type], name: 'index_assetable'
  end
end
