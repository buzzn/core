class CreateDocuments < ActiveRecord::Migration

  def change
    create_table :documents do |t|
      t.string :path, null: false, limit: 128
      t.string :encryption_details, null: false, limit: 512

      t.string :mime, null: false
      t.string :sha256, null: false
      t.integer :size, null: false

      t.timestamps null: false
    end
    add_index :documents, [:path], unique: true
  end

end
