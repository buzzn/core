require_relative 'base_roda'
class MeRoda < BaseRoda

  route do |r|

    r.root do
      if current_user.nil?
        raise Buzzn::PermissionDenied.create(Person, :retrieve, nil)
      end
      PersonResource.all(current_user, ContractingPartyPersonResource)
        .retrieve(current_user.person.id)
    end
  end
end
