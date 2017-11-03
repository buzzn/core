require_relative 'tariff_create'
TariffConstraints = Buzzn::Schemas.Form(TariffCreate) do
  optional(:end_date).filled(:date?)
end
