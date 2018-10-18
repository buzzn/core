require_relative '../meter'
require_relative '../../../constraints/meter/base'

Schemas::Transactions::Admin::Meter::UpdateReal = Schemas::Support.Form(Schemas::Constraints::Meter::Base) do
  required(:updated_at).filled(:date_time?)
  optional(:product_serialnumber).filled(:alphanumeric?, max_size?: 128, min_size?: 4)
end
