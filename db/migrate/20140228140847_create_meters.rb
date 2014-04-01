class CreateMeters < ActiveRecord::Migration
  def change
    create_table :meters do |t|
      t.string  :slug
      t.string  :address
      t.float   :latitude
      t.float   :longitude
      t.decimal :uid, precision: 15
      t.boolean :public
      t.string  :api_type
      t.string  :username
      t.string  :password

      t.timestamps
    end
  end
end
