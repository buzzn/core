class AddFieldsToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :price_cents_per_kwh, :float
    add_column :contracts, :price_cents_per_month, :integer
    add_column :contracts, :discount_cents_per_month, :integer
    add_column :contracts, :other_contract, :boolean
    add_column :contracts, :move_in, :boolean
    add_column :contracts, :beginning, :date
    add_column :contracts, :authorization, :boolean
    add_column :contracts, :feedback, :text
    add_column :contracts, :attention_by, :text
  end
end
