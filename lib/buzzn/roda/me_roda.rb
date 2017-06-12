require_relative 'base_roda'
class MeRoda < BaseRoda

  route do |r|

    r.root do
      if current_user.nil?
        raise Buzzn::PermissionDenied.create(User, :retrieve, nil)
      end
      # use the normal loading semantic to produce consistent results
      ContractingPartyUserResource.retrieve(current_user, current_user.id)
    end
  end
end
