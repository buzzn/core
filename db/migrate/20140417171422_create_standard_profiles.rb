class CreateStandardProfiles < ActiveRecord::Migration
  def change
    create_table :standard_profiles do |t|
      t.string   :mode
      t.string   :category
      t.datetime :date
      t.decimal  :wh

      t.timestamps
    end
  end
end
