require_relative '../meter'
require_relative '../../../constraints/meter/base'
require_relative '../register/create_meta'

Schemas::Transactions::Admin::Meter::CreateReal = Schemas::Support.Form(Schemas::Constraints::Meter::Base) do
  required(:registers).filled { each(Schemas::Transactions::Admin::Register::CreateMetaLoose) }
  optional(:metering_location_id).maybe(:str?, size?: 33)
  optional(:product_serialnumber).filled(:alphanumeric?, max_size?: 128, min_size?: 4)
end
