require_relative '../organization'
require_relative '../../../schemas/transactions/organization/update'

module Transactions::Admin::Organization
  class UpdateOrganizationMarket < Transactions::Base

    validate :schema
    check :authorize, with: :'operations.authorization.update'
    around :db_transaction
    tee :create_or_update_address, with: :'operations.action.create_or_update_address'
    map :update_org, with: :'operations.action.update'

    def schema(resource:, **)
      Schemas::Transactions::Organization.update_for(resource)
    end

  end
end
