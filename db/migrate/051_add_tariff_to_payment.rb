class AddTariffToPayment < ActiveRecord::Migration

  def up
    add_belongs_to :payments, :tariff, reference: :tariffs, null: true, index: true
    add_foreign_key :payments, :tariffs, name: :fk_payments_tariffs, column: :tariff_id
  end

  def down
    remove_foreign_key :billings, name: :fk_billings_adjusted_payments
    remove_belongs_to :billings, :adjusted_payment
  end

end
