require_relative '../register'

Schemas::Transactions::Admin::Register::UpdateVirtual = Buzzn::Schemas.Form(Schemas::Constraints::Register::Common) do
  optional(:direction).value(included_in?: Register::Base.directions.values)
  required(:updated_at).filled(:date_time?)
end
