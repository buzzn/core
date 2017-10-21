require_relative 'support/form'
TariffCreate = Buzzn::Schemas.Form do
  required(:name).filled(:str?)
  required(:begin_date).filled(:date?)
  required(:energyprice_cents_per_kwh).filled(:float?)
  required(:baseprice_cents_per_month).filled(:int?)
end
