require_relative '../constraints'

Schemas::Constraints::MarketLocation = Schemas::Support.Form do
  required(:name).filled(:str?, max_size?: 64)
  required(:group_id).filled(:int?, gteq?: 1)
  optional(:market_location_id).filled(:str?, size?: 11)
end
