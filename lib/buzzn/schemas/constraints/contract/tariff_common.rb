module Schemas
  module Constraints
    module Contract
    end
  end
end
#require_relative '../contract'

Schemas::Constraints::Contract::TariffCommon = Buzzn::Schemas.Form do
  required(:name).filled(:str?, max_size?: 64)
  required(:begin_date).filled(:date?)
  required(:energyprice_cents_per_kwh).filled(:float?, gt?: 0)
  required(:baseprice_cents_per_month).filled(:int?, gt?: 0)
end
