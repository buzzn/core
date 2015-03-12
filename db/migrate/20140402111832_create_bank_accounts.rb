class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string  :holder
      t.string  :encrypted_iban
      t.string  :bic
      t.string  :bank_name
      t.boolean :direct_debit

      t.integer :bank_accountable_id
      t.string  :bank_accountable_type

      t.timestamps
    end
    add_index :bank_accounts, [:bank_accountable_id, :bank_accountable_type], name: 'index_accountable'
  end
end


