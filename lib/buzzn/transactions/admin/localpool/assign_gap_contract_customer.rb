require_relative 'gap_contract_customer_base'

module Transactions::Admin::Localpool
  class AssignGapContractCustomer < GapContractCustomerBase

    authorize :allowed_roles
    around :db_transaction
    map :assign_gap_contract_customer

    def allowed_roles(permission_context:)
      permission_context.owner.update
    end

  end
end
