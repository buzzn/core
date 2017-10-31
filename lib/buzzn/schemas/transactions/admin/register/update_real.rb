require_relative '../register'
require_relative '../../../constraints/register/common'

Schemas::Transactions::Admin::Register::UpdateReal = Buzzn::Schemas.Form(Schemas::Constraints::Register::Common) do
  optional(:name).filled(:str?, max_size?: 64)
  # note: direction is immutable on real registers as it is bound to the type !
  optional(:low_load_ability).filled(:bool?)
  required(:updated_at).filled(:date_time?)
end
