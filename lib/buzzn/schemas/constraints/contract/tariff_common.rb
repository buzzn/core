require_relative '../contract'

Schemas::Constraints::Contract::TariffCommon = Schemas::Support.Form do
  required(:name).filled(:str?, max_size?: 64)
  required(:begin_date).filled(:date?)
  required(:energyprice_cents_per_kwh).filled(:float?, gt?: 0)
  required(:baseprice_cents_per_month).filled(:float?, gt?: 0)
end
