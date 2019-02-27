require_relative 'owner_base'
require_relative '../../admin/generic/update_nested_person.rb'

module Transactions::Admin::Localpool
  class UpdatePersonOwner < OwnerBase

    add :old_owner
    add :new_owner
    map :setup_new_roles

    def new_owner(resource:, params:, **)
      res = Transactions::Admin::Generic::UpdateNestedPerson.(resource: resource.owner, params: params)
      if res.success?
        res.value!
      end
    end

  end
end
