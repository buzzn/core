require_relative '../constraints'

Schemas::Constraints::OrganizationMarketFunction = Schemas::Support.Form do
  required(:market_partner_id).filled(:str?, max_size?: 64)
  required(:edifact_email).filled(:str?, :email?, max_size?: 64)
  required(:function).value(included_in?: OrganizationMarketFunction.functions.values)
end
