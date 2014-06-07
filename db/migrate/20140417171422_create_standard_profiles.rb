class CreateStandardProfiles < ActiveRecord::Migration
  def change
    create_table :standard_profiles do |t|
      t.string   :mode
      t.string   :category
      t.datetime :date
      t.decimal  :watt_hour

      t.timestamps
    end
  end
end
