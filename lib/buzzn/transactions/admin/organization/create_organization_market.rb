require_relative '../organization'
require_relative '../../../schemas/transactions/organization/create'

module Transactions::Admin::Organization
  class CreateOrganizationMarket < Transactions::Base

    validate :schema
    authorize :allowed_roles
    around :db_transaction
    tee :create_address, with: 'operations.action.create_address'
    tee :functions
    map :wrap_up, with: 'operations.action.create_item'

    def schema
      Schemas::Transactions::Organization::CreateMarketWithNested
    end

    def allowed_roles(permission_context:)
      permission_context.create
    end

    include Import['operations.action.create_address', 'operations.action.create_person']

    def functions(params:, **)
      params[:market_functions] = params.delete(:functions).each_with_index.map do |functionp, idx|
        raise Buzzn::ValidationError, {:functions => { idx => {:market_partner_id => ["#{functionp[:market_partner_id]} already exists"] }}} if Organization::MarketFunction.where(:market_partner_id => functionp[:market_partner_id]).any?
        create_address.(params: functionp)
        create_address.(params: functionp[:contact_person] || {})
        create_person.(params: functionp, method: :contact_person)
        ::Organization::MarketFunction.create(functionp)
      end
    end

    def wrap_up(params:, resource:)
      Organization::MarketResource.new(
        *super(resource, params)
      )
    end

  end
end
