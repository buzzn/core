require_relative 'gap_contract_customer_base'
require_relative '../../../schemas/transactions/person/create'

module Transactions::Admin::Localpool
  class CreatePersonGapContractCustomer < GapContractCustomerBase

    validate :schema
    authorize :allowed_roles
    around :db_transaction
    tee :create_address, with: :'operations.action.create_address'
    add :new_customer, with: :'operations.action.create_item'
    map :assign_gap_contract_customer # from super-class

    def schema
      Schemas::Transactions::Person::CreateWithAddress
    end

    def allowed_roles(permission_context:)
      permission_context.owner.create
    end

    def new_customer(params:, resource:)
      PersonResource.new(
        *super(resource.persons, params)
      )
    end

  end
end
