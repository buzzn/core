require_relative '../meter'
require_relative '../../../constraints/meter/base'

Schemas::Transactions::Admin::Meter::UpdateReal = Buzzn::Schemas.Form(Schemas::Constraints::Meter::Base) do
  required(:updated_at).filled(:date_time?)
end
