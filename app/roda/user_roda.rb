class UserRoda < BaseRoda

  route do |r|

    r.is 'me' do
      if current_user.nil?
        raise Buzzn::PermissionDenied.create(User, :retrieve, nil)
      end
      # use the normal loading semantic to produce consistent results
      UserSingleResource.retrieve(current_user, current_user.id)
    end

    r.get! do
      UserResource.all(current_user, r.params['filter'])
    end

    r.on :id do |id|
      user = UserSingleResource.retrieve(current_user, id)

      r.get! do
        user
      end

      r.get! 'profile' do |id|
        user.profile
      end

      r.get! 'bank-accounts' do |id|
        user.bank_accounts
      end

      r.get! 'meters' do |id|
        user.meters(r.params['filter'])
      end
    end
  end
end
