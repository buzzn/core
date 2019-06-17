require_relative '../market_function'
require_relative '../../../schemas/transactions/market_function/create'
require_relative 'base'

module Transactions::Admin::MarketFunction
  class Create < Base

    validate :schema
    authorize :allowed_roles
    around :db_transaction
    tee :create_contact_person_address, with: 'operations.action.create_address'
    tee :create_contact_person, with: 'operations.action.create_person'
    tee :create_address, with: 'operations.action.create_address'
    map :wrap_up, with: 'operations.action.create_item'

    def schema(resource:, organization:, **)
      Schemas::Transactions::MarketFunction.create_for(organization)
    end

    def allowed_roles(permission_context:)
      permission_context.create
    end

    def create_contact_person_address(params:, **)
      super(params: params[:contact_person] || {})
    end

    def create_contact_person(params:, **)
      super(params: params, method: :contact_person)
    end

    def wrap_up(params:, resource:, **)
      Organization::MarketFunctionResource.new(
        *super(resource, params)
      )
    end

  end
end
