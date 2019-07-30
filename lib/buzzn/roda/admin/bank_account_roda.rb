require_relative '../admin_roda'
require_relative '../../transactions/admin/bank_account/create'
require_relative '../../transactions/admin/bank_account/update'
require_relative '../../transactions/admin/bank_account/delete'

class Admin::BankAccountRoda < BaseRoda

  PARENT = :bank_account_parent

  plugin :shared_vars

  route do |r|

    parent = shared[PARENT]

    r.post! do
      Transactions::Admin::BankAccount::Create.(
        resource: parent, params: r.params
      )
    end

    bank_accounts = parent.bank_accounts

    r.get! do
      bank_accounts
    end

    r.is :id do |id|

      bank_account = bank_accounts.retrieve(id)

      r.get! do
        bank_account
      end

      r.patch! do
        Transactions::Admin::BankAccount::Update.(
          resource: bank_account, params: r.params
        )
      end

      r.delete! do
        Transactions::Admin::BankAccount::Delete.(
          resource: bank_account
        )
      end
    end
  end

end
