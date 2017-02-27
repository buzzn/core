class BankAccountRoda < BaseRoda

  include Import.args[:env, 'transaction.update_bank_account']

  route do |r|

    r.is :id do |id|

      bank_account = BankAccountResource.retrieve(current_user, id)

      r.patch do
        update_bank_account.call(r.params, resource: [bank_account])
      end
    end
  end
end
