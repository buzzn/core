require_relative '../organization'

Schemas::Constraints::Organization::MarketFunction = Schemas::Support.Form do
  required(:market_partner_id).filled(:str?, max_size?: 64)
  required(:edifact_email).filled(:str?, :email?, max_size?: 64)
  required(:function).value(included_in?: Organization::MarketFunction.functions.values)
end
