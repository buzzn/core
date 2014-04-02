class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :holder
      t.string :iban
      t.string :bic

      t.string :user_id
      t.timestamps
    end
  end
end
