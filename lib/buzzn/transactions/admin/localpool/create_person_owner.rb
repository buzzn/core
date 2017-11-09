require_relative 'assign_owner_base'

module Transactions::Admin::Localpool
  class CreatePersonOwner < AssignOWnerBase
    def self.for(localpool)
      new.with_step_args(
        validate: [Schemas::Transactions::Admin::Person::Create],
        authorize: [localpool, localpool.permissions.owner.create],
        persist: [localpool]
      )
    end

    step :validate, with: 'operations.validation'
    step :authorize, with: :'operations.authorize.generic'
    step :persist

    def persist(input, localpool)
      Group::Localpool.transaction do
        context = localpool.context.owner
        person = PersonResource.new(Person.create!(input), context)
        Right(assign_owner(localpool, person))
      end
    end
  end
end
