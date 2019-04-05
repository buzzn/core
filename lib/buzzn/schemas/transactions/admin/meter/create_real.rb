require_relative '../meter'
require_relative '../../../constraints/meter/base'
require_relative '../register/create_meta'

Schemas::Transactions::Admin::Meter::CreateReal = Schemas::Support.Form(Schemas::Constraints::Meter::Base) do
  required(:registers).filled { each(Schemas::Transactions::Admin::Register::CreateMetaLoose) }
  required(:product_serialnumber).filled(:str?, max_size?: 128, min_size?: 4)
  required(:converter_constant).value(:int?, gteq?: 1)
  optional(:metering_location_id).maybe(:str?, size?: 33)
end
