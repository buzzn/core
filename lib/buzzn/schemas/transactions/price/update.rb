require_relative '../price'

Schemas::Transactions::Price::Update = Buzzn::Schemas.Form(Schemas::Transactions::Update) do
  optional(:name).filled(:str?)
  optional(:begin_date).filled(:date?)
  optional(:energyprice_cents_per_kilowatt_hour).filled(:float?)
  optional(:baseprice_cents_per_month).filled(:int?)
end
