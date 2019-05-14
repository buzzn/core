require_relative '../localpool'

module Transactions::Admin::Localpool

  class AssignOrganizationMarket < Transactions::Base

    validate :schema
    check :authorize, with: :'operations.authorization.update'
    add :fetch_organization
    tee :assign_organization
    map :wrap_up, with: :'operations.action.update'

    def schema
      Schemas::Transactions::Admin::Localpool::AssignOrganizationMarket
    end

    def fetch_organization(resource:, params:, **)
      Organization::Market.find(params.delete(:organization_id))
    end

    def assign_organization(resource:, function:, fetch_organization:, params:, **)
      params[function] = fetch_organization
    end

  end

end
