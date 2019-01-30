require_relative '../payment'

module Transactions::Admin::Contract::Base::Payment
  class Update < Transactions::Base

    validate :schema
    check :authorize, with: 'operations.authorization.update'
    around :db_transaction
    map :update_payment, with: 'operations.action.update'

    def schema
      Schemas::Transactions::Admin::Contract::Payment::Update
    end

  end
end
