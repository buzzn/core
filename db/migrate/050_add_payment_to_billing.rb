class AddPaymentToBilling < ActiveRecord::Migration

  def up
    add_belongs_to :billings, :adjusted_payment, reference: :payments, null: true, index: true
    add_foreign_key :billings, :payments, name: :fk_billings_adjusted_payments, column: :adjusted_payment_id
  end

  def down
    remove_foreign_key :billings, name: :fk_billings_adjusted_payments
    remove_belongs_to :billings, :adjusted_payment
  end

end
