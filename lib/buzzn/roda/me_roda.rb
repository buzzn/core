require_relative 'base_roda'
class MeRoda < BaseRoda

  route do |r|

    r.root do
      if current_user.nil?
        raise Buzzn::PermissionDenied.create(User, :retrieve, nil)
      end
      UserResource.all(current_user, ContractingPartyUserResource)
        .retrieve(current_user.id)
    end
  end
end
