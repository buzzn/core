require_relative 'tariff_create'
TariffContraints = Buzzn::Schemas.Form(TariffCreate) do
  optional(:end_date).filled(:date?)
end
