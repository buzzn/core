require_relative 'owner_base'

module Transactions::Admin::Localpool
  class AssignOwner < OwnerBase
    def self.for(localpool)
      new.with_step_args(
        authorize: [localpool, *localpool.permissions.owner.update],
        persist: [localpool]
      )
    end

    step :authorize, with: :'operations.authorization.generic'
    step :persist

    def persist(input, localpool)
      Group::Localpool.transaction do
        Right(assign_owner(localpool, input))
      end
    end
  end
end
