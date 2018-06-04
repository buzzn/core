require_relative '../register'
require_relative '../../../../schemas/constraints/register/common'

Schemas::Transactions::Admin::Register::UpdateVirtual = Schemas::Support.Form(Schemas::Constraints::Register::Common) do
  optional(:direction).value(included_in?: Register::Base.directions.values)
  required(:updated_at).filled(:date_time?)
end
