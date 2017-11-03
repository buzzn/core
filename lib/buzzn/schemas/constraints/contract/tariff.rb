require_relative 'tariff_common'

Schemas::Constraints::Contract::Tariff = Buzzn::Schemas.Form(Schemas::Constraints::Contract::Tariff) do
  optional(:end_date).filled(:date?)
end
