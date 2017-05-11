class UserRoda < BaseRoda
  plugin :shared_vars

  route do |r|

    users = shared[:localpool].users

    r.get! do
      users.filter(r.params['filter'])
    end

    r.on :id do |id|
      user = users.retrieve(current_user, id)

      r.get! do
        user
      end

      r.on 'bank-accounts' do |id|
        shared[:bank_account_parent] = user
        r.run BankAccountRoda
      end
    end
  end
end
