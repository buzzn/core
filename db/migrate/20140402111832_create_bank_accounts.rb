class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string  :holder
      t.string  :iban
      t.string  :bic
      t.string  :bank_name
      t.boolean :direct_debit
      
      t.integer :bank_accountable_id
      t.string  :bank_accountable_type

      t.timestamps
    end
  end
end
