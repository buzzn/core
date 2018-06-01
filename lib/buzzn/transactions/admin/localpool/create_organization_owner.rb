require_relative 'owner_base'

module Transactions::Admin::Localpool
  class CreateOrganizationOwner < OwnerBase

    validate :schema
    authorize :allowed_roles
    around :db_transaction
    map :create_organization, with: :'operations.action.create_item'
    map :assign_owner

    def schema
      Schemas::Transactions::Admin::Organization::Create
    end

    def allowed_roles(permission_context:)
      permission_context.owner.create
    end

    def create_organization(params:, resource:)
      attrs = params.merge(mode: :other)
      OrganizationResource.new(
        *super(resource.organizations, attrs)
      )
    end

  end
end
