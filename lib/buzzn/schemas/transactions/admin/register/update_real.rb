require_relative '../register'
require_relative '../../../constraints/register/common'

Schemas::Transactions::Admin::Register::UpdateReal = Schemas::Support.Form(Schemas::Constraints::Register::Common) do
  optional(:metering_point_id).filled(:str?, size?: 11)
  # note: direction is immutable on real registers as it is bound to the type !
  required(:updated_at).filled(:date_time?)
end
