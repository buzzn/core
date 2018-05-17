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
      Schemas::Transactions::Admin::Organization::Create
    end

    def persist(input, localpools)
      Group::Localpool.transaction do
        context = localpool.context.owner
        organization = OrganizationResource.new(Organization.create!(input.merge(mode: :other), context))
        Success(assign_owner(localpool, organization))
      end
    end

  end
end
