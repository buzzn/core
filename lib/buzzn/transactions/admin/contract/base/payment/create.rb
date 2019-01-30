require_relative '../payment'

module Transactions::Admin::Contract::Base::Payment
  class Create < Transactions::Base

    validate :schema
    check :authorize, with: 'operations.authorization.create'
    around :db_transaction
    map :create_payment, with: 'operations.action.create_item'

    def schema
      Schemas::Transactions::Admin::Contract::Payment::Create
    end

    def create_payment(params:, resource:, **)
      Contract::PaymentResource.new(
        *super(resource, params)
      )
    end

  end
end
