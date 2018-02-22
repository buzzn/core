require_relative '../meter'

Schemas::Constraints::Meter::Common = Schemas::Support.Form do
  optional(:product_serialnumber).filled(:str?, max_size?: 128, min_size?: 4)
end
