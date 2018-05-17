require_relative 'owner_base'

module Transactions::Admin::Localpool
  class CreatePersonOwner < OwnerBase

    def self.for(localpool)
      new.with_step_args(
        authorize: [localpool, localpool.permissions.owner.create],
        persist: [localpool]
      )
    end

    validate :schema
    step :authorize, with: :'operations.authorize.generic'
    step :persist

    def schema
      Schemas::Transactions::Admin::Person::Create
    end

    def persist(input, localpool)
      Group::Localpool.transaction do
        context = localpool.context.owner
        person = PersonResource.new(Person.create!(input), context)
        Success(assign_owner(localpool, person))
      end
    end

  end
end
