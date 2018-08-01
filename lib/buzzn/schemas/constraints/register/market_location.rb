require_relative '../register'

Schemas::Constraints::Register::MarketLocation = Schemas::Support.Form do
  optional(:market_location_id).filled(:str?, size?: 11)
end
