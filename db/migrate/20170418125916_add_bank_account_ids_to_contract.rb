class AddBankAccountIdsToContract < ActiveRecord::Migration
  def up
    add_column :contracts, :customer_bank_account_id, :uuid
    add_column :contracts, :contractor_bank_account_id, :uuid

    remove_column :bank_accounts, :bank_accountable_id, :uuid
    remove_column :bank_accounts, :bank_accountable_type, :string

    add_column :bank_accounts, :contracting_party_id, :uuid
    add_column :bank_accounts, :contracting_party_type, :string
  end

  def down
    remove_column :contracts, :customer_bank_account_id, :uuid
    remove_column :contracts, :contractor_bank_account_id, :uuid

    add_column :bank_accounts, :bank_accountable_id, :uuid
    add_column :bank_accounts, :bank_accountable_type, :string

    remove_column :bank_accounts, :contracting_party_id, :uuid
    remove_column :bank_accounts, :contracting_party_type, :string
  end
end
