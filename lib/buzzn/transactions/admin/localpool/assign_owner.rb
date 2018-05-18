require_relative 'owner_base'

module Transactions::Admin::Localpool
  class AssignOwner < OwnerBase

    authorize :allowed_roles
    around :db_transaction
    map :assign_owner

    def allowed_roles(permission_context:)
      permission_context.owner.update
    end

  end
end
