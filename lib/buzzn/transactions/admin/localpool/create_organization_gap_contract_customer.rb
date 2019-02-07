require_relative 'gap_contract_customer_base'
require_relative 'create_organization_base'

module Transactions::Admin::Localpool
  class CreateOrganizationGapContractCustomer < GapContractCustomerBase

    include CreateOrganizationBase

    validate :schema
    authorize :allowed_roles
    around :db_transaction
    tee :create_address, with: :'operations.action.create_address'
    tee :create_contact_address, with: :'operations.action.create_address'
    tee :create_contact, with: :'operations.action.create_person'
    tee :create_legal_representation, with: :'operations.action.create_person'
    add :new_organization, with: :'operations.action.create_item'
    map :assign_gap_contract_customer # from super-class

    def allowed_roles(permission_context:)
      permission_context.owner.create
    end

    def assign_gap_contract_customer(new_organization:, resource:, **)
      super(new_customer: new_organization, resource: resource)
    end

  end
end
