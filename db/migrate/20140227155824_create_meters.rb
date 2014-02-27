class CreateMeters < ActiveRecord::Migration
  def change
    create_table :meters do |t|
      t.string :name

      t.timestamps
    end
  end
end
