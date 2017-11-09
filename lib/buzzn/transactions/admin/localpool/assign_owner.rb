require_relative 'assign_owner_base'

module Transactions::Admin::Localpool
  class AssignOwner < AssignOwnerBase
    def self.for(localpool)
      new.with_step_args(
        authorize: [localpool, localpool.permissions.owner.update],
        persist: [localpool]
      )
    end

    step :authorize, with: :'operations.authorize.generic'
    step :persist

    def persist(input, localpool)
      Group::Localpool.transaction do
        Right(assign_owner(input))
      end
    end
  end
end
