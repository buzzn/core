class CreateDocument < ActiveRecord::Migration
  def change
    create_table :documents, id: :uuid do |t|
      t.string :path, null: false
      t.string :encryption_details, null: false
      
      t.timestamps null: false
    end
    add_index :documents, [:path], unique: true
  end
end
