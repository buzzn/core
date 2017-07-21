require_relative 'base_roda'
class MeRoda < BaseRoda

  include Import.args[:env,
                      'transaction.update_person']

  route do |r|

    if current_user.nil?
      raise Buzzn::PermissionDenied.new(Person, :retrieve, nil)
    end

    person = PersonResource.all(current_user, ContractingPartyPersonResource)
               .retrieve(current_user.person.id)

    r.get! do
      person
    end

    r.patch! do
      update_person.call(r.params, resource: [person])
    end
  end
end
