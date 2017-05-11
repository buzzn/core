class UserLegacyRoda < BaseRoda
  plugin :shared_vars

  route do |r|

    r.is 'me' do
      r.run MeRoda
    end

    r.get! do
      UserResource.all(current_user, r.params['filter'])
    end

    r.on :id do |id|
      user = UserResource.retrieve(current_user, id)

      r.get! do
        user
      end

      r.get! 'profile' do |id|
        ProfileResource.new(user.object.profile, current_user: current_user)
      end

      r.on 'bank-accounts' do |id|
        shared[:bank_account_parent] = user
        r.run BankAccountRoda
      end
    end
  end
end
