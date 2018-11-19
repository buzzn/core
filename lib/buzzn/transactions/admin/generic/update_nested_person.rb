require_relative '../../../schemas/transactions/person/update'
require_relative '../generic'

module Transactions::Admin::Generic
  class UpdateNestedPerson < Transactions::Base

    validate :schema
    authorize :allowed_roles
    around :db_transaction
    tee :create_or_update_address, with: :'operations.action.create_or_update_address'
    map :update_person, with: :'operations.action.update'

    def schema(resource:, **)
      Schemas::Transactions::Person.update_for(resource)
    end

    def allowed_roles(permission_context:)
      permission_context.update
    end

  end
end
