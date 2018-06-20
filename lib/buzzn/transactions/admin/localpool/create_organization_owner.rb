require_relative 'owner_base'
require_relative '../../../schemas/transactions/organization/create_with_nested'

module Transactions::Admin::Localpool
  class CreateOrganizationOwner < OwnerBase

    validate :schema
    authorize :allowed_roles
    around :db_transaction
    tee :create_address, with: :'operations.action.create_address'
    add :new_owner, with: :'operations.action.create_item'
    map :assign_owner # from super-class

    def schema
      Schemas::Transactions::Organization::CreateWithNested
    end

    def allowed_roles(permission_context:)
      permission_context.owner.create
    end

    def new_owner(params:, resource:)
      OrganizationResource.new(
        *super(resource.organizations, params)
      )
    end

  end
end
