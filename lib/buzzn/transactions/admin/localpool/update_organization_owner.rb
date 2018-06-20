require_relative 'owner_base'
require_relative '../../../schemas/transactions/organization/update'

module Transactions::Admin::Localpool
  class UpdateOrganizationOwner < OwnerBase

    validate :schema
    authorize :allowed_roles
    around :db_transaction
    tee :create_or_update_address, with: :'operations.action.create_or_update_address'
    map :update_organization, with: :'operations.action.update'

    def schema(resource:, **)
      Schemas::Transactions::Organization.update_for(resource)
    end

    def allowed_roles(permission_context:)
      permission_context.update
    end

  end
end
