class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents, id: :uuid do |t|
      t.string :path, null: false, size: 128
      t.string :encryption_details, null: false, size: 256

      t.timestamps null: false
    end
    add_index :documents, [:path], unique: true
  end
end
