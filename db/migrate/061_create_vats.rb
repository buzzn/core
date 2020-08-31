class CreateVats < ActiveRecord::Migration

  def up
    create_table :vats, id: false do |t|
      t.decimal :amount, null: false
      t.date :begin_date, null: false
      t.index [:begin_date], unique: true
    end
  end

  def down
    drop_table :vats
  end
end
