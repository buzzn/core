# Replaces the core config with vats. Creates a default vat,
# which was valid from 1.1.2007 and sets it to all the billing items.
class CreateVats < ActiveRecord::Migration

  def up
    create_table :vats, id: false do |t|
      t.decimal :amount, null: false
      t.date :begin_date, null: false, :primary_key => true
      t.index [:begin_date]
    end

    add_column :billing_items, :vat, :date
    add_foreign_key :billing_items, :vats, column: :vat, primary_key: :begin_date
    default_vat = Vat.new(begin_date: Date.new(2007, 1, 1), amount: 1.19)
    default_vat.save
    Vat.new(begin_date: Date.new(2020, 7, 1), amount: 1.16).save

    BillingItem.all.each {|i| i.vat = default_vat; i.save}
    change_column_null(:billing_items, :vat, false)
  end

  def down
    remove_column :billing_items, :vat
    drop_table :vats
    create_table :core_configs do |t|
      t.string :namespace, null: false, size: 64
      t.string :key, null: false, size: 64
      t.string :value, null: false, size: 256
    end
    create_table :core_configs do |t|
      t.string :namespace, null: false, size: 64
      t.string :key, null: false, size: 64
      t.string :value, null: false, size: 256
    end
  end

end
