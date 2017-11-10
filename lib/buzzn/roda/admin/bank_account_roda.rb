require_relative '../admin_roda'
class Admin::BankAccountRoda < BaseRoda

  PARENT = :bank_account_parent

  plugin :shared_vars
  plugin :created_deleted

  include Import.args[:env,
                      'transaction.create_bank_account',
                      'transaction.update_bank_account']

  route do |r|

    parent = shared[PARENT]

    r.post! do
      created do
        create_bank_account.call(r.params,
                                 resource: [parent.method(:create_bank_account)])
      end
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
        update_bank_account.call(r.params, resource: [bank_account])
      end

      r.delete! do
        deleted do
          bank_account.delete
        end
      end
    end
  end
end
