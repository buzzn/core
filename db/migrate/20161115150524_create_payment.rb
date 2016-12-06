class CreatePayment < ActiveRecord::Migration
  def change
    create_table :payments, id: :uuid do |t|
      t.date :begin_date, null: false
      t.date :end_date
      t.integer :price_cents, null: false
      t.string :cycle
      t.string :source
      t.belongs_to :contract, index: true, foreign_key: true, type: :uuid, null: false
    end
  end
end
