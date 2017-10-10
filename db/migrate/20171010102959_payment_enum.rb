class PaymentEnum < ActiveRecord::Migration
  def change
    create_enum :cycle, *Contract::Payment::CYCLES

    remove_column :payments, :cycle

    add_column :payments, :cycle, :cycle, null: true, index: true
  end
end
