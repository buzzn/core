class CreateProfiles < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :profiles, id: :uuid do |t|

      t.string :user_name
      t.string :slug
      t.string :title
      t.string :image
      t.string :first_name
      t.string :last_name
      t.text   :about_me
      t.string :website
      t.string :facebook
      t.string :twitter
      t.string :xing
      t.string :linkedin
      t.string :gender
      t.string :phone
      t.string :time_zone
      t.text   :know_buzzn_from
      t.boolean :confirm_pricing_model
      t.boolean :terms
      t.string :readable

      # notifications
      t.boolean :newsletter_notifications,  :default => true
      t.boolean :location_notifications,    :default => true
      t.boolean :group_notifications,       :default => true


      t.belongs_to :user, type: :uuid

      t.timestamps
    end
    add_index :profiles, :slug,                 unique: true
    add_index :profiles, :user_name,            unique: true
    add_index :profiles, :user_id
    add_index :profiles, :readable
  end
end
