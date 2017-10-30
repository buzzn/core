require_relative 'create_virtual'

Schemas::Transactions::Admin::Meter::UpdateVirtual = Buzzn::Schemas.Form(Schemas::Transactions::Admin::Meter::CreateVirtual) do
  required(:updated_at).filled(:date_time?)
end
