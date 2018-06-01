require_relative '../admin_roda'

class Admin::BankAccountRoda < BaseRoda

  include Import.args[:env,
                      'transactions.admin.bank_account.create',
                      'transactions.admin.bank_account.update',
                      'transactions.admin.bank_account.delete',
                     ]

  PARENT = :bank_account_parent

  plugin :shared_vars

  route do |r|

    parent = shared[PARENT]

    r.post! do
      create.(resource: parent, params: r.params)
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
        update.(resource: bank_account, params: r.params)
      end

      r.delete! do
        delete.(resource: bank_account)
      end
    end
  end

end
