require_relative '../constraints'

Schemas::Constraints::Price = Buzzn::Schemas.Form do
  required(:name).filled(:str?)
  required(:begin_date).filled(:date?)
  required(:energyprice_cents_per_kilowatt_hour).filled(:float?)
  required(:baseprice_cents_per_month).filled(:int?)
end
