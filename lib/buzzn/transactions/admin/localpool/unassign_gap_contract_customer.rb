require_relative 'gap_contract_customer_base'

module Transactions::Admin::Localpool
  class UnassignGapContractCustomer < GapContractCustomerBase

    authorize :allowed_roles
    around :db_transaction
    map :unassign_and_delete_gap_contract_customer #super class

    def allowed_roles(permission_context:)
      permission_context.owner.create
    end

    def unassign_and_delete_gap_contract_customer(resource:, **)
      super(resource: resource)
    end

  end
end
