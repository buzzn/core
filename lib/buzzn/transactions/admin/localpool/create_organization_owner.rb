require_relative 'assign_owner_base'

module Transactions::Admin::Localpool
  class CreatePersonOwner < AssignOwnerBase
    def self.for(localpool)
      new.with_step_args(
        validate: [Schemas::Transactions::Admin::Organization::Create],
        authorize: [localpool, localpool.permissions.owner.create],
        persist: [localpool]
      )
    end

    step :validate, with: 'operations.validation'
    step :authorize, with: :'operations.authorize.generic'
    step :persist

    def persist(input, localpools)
      Group::Localpool.transaction do
        context = localpool.context.sub_context(:owner)
        organization = OrganizationResource.new(Organization.create!(input.merge(mode: :other), context)
        Right(assign_owner(organization))
      end
    end
  end
end
