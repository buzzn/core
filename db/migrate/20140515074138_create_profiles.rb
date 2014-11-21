class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|

      t.string :username
      t.text :description
      t.string :slug
      t.string :title
      t.string :image
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.string :phone
      t.string :time_zone
      t.text   :know_buzzn_from
      t.boolean :confirm_pricing_model
      t.boolean :terms

      # notifications
      t.boolean :newsletter_notifications,  :default => true
      t.boolean :location_notifications,    :default => true
      t.boolean :group_notifications,       :default => true


      t.integer  :user_id

      t.timestamps
    end
    add_index :profiles, :slug,                 unique: true
    add_index :profiles, :username,             unique: true
    add_index :profiles, :user_id
  end
end
