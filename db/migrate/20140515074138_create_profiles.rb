class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|

      t.integer  :user_id

      t.string :slug
      t.string :image
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.string :phone
      t.string :title
      t.text :know_buzzn_from

      t.boolean :confirm_pricing_model,   :default => false

      # notifications
      t.boolean :newsletter_notifications,  :default => true
      t.boolean :meter_notifications,       :default => true
      t.boolean :group_notifications,       :default => true

      t.timestamps
    end
    add_index :profiles, :slug,                 unique: true
  end
end
