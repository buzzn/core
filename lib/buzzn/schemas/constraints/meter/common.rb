require_relative '../meter'

Schemas::Constraints::Meter::Common = Buzzn::Schemas.Form do
  optional(:product_name).filled(:str?, max_size?: 64)
  optional(:product_serialnumber).filled(:str?, max_size?: 128, min_size?: 4)
end
