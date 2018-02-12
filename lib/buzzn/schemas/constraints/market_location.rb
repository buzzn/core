require_relative '../constraints'

Schemas::Constraints::MarketLocation = Schemas::Support.Form do
  required(:name).filled(:str?, max_size?: 64)
  # TODO: use size?: 11 here. If I do that though, the DB column limit isn't set to 11.
  optional(:market_location_id).filled(:str?, min_size?: 11, max_size?: 11)
end
