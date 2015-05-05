class CreateVersions < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :versions, id: :uuid do |t|
      t.string   :item_type, :null => false
      t.belongs_to  :item,   :null => false, type: :uuid
      t.string   :event,     :null => false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
    end
    add_index :versions, [:item_type, :item_id]
  end
end
