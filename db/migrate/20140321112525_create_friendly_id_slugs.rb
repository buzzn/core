class CreateFriendlyIdSlugs < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :friendly_id_slugs do |t|
      t.string   :slug,           :null => false
      t.belongs_to  :sluggable,   :null => false, type: :uuid
      t.string   :sluggable_type, :limit => 50
      t.string   :scope
      t.datetime :created_at
    end
    add_index :friendly_id_slugs, :sluggable_id
    add_index :friendly_id_slugs, [:slug, :sluggable_type]
    add_index :friendly_id_slugs, [:slug, :sluggable_type, :scope], :unique => true
    add_index :friendly_id_slugs, :sluggable_type
  end
end
