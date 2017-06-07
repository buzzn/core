class MeRoda < BaseRoda

  route do |r|

    r.get! do
      if current_user.nil?
        raise Buzzn::PermissionDenied.create(User, :retrieve, nil)
      end
      # use the normal loading semantic to produce consistent results
      ContractingPartyUserResource.retrieve(current_user, current_user.id)
    end
  end
end
