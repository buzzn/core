class CreateBankAccountsOld < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :bank_accounts, id: :uuid do |t|
      t.string  :slug
      t.string  :holder
      t.string  :encrypted_iban
      t.string  :bic
      t.string  :bank_name
      t.boolean :direct_debit

      t.belongs_to :bank_accountable, type: :uuid
      t.string  :bank_accountable_type

      t.timestamps
    end
    add_index :bank_accounts, :slug, :unique => true
    add_index :bank_accounts, [:bank_accountable_id, :bank_accountable_type], name: 'index_accountable'
  end
end
