require_relative '../market_function'
require_relative '../../../schemas/transactions/market_function/update'
require_relative 'base'

module Transactions::Admin::MarketFunction
  class Update < Base

    validate :schema
    authorize :allowed_roles
    around :db_transaction

    tee :check_relation

    tee :create_or_update_contact_person_address, with: :'operations.action.create_or_update_address'
    tee :create_or_update_contact_person, with: :'operations.action.create_or_update_person'

    tee :create_or_update_address, with: :'operations.action.create_or_update_address'
    map :update_function, with: :'operations.action.update'

    def schema(resource:, organization:, **)
      Schemas::Transactions::MarketFunction.update_for(resource, organization)
    end

    def allowed_roles(permission_context:)
      permission_context.update
    end

    def create_or_update_contact_person_address(params:, resource:, **)
      super(params: params[:contact_person] || {}, resource: resource.contact_person)
    end

    def create_or_update_contact_person(params:, resource:, **)
      super(params: params, method: :contact_person, force_new: false, resource: resource)
    end

  end
end
