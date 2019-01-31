require_relative '../payment'

Schemas::Transactions::Admin::Contract::Payment::Create = Schemas::Support.Form do
  required(:begin_date).filled(:date?)
  required(:energy_consumption_kwh_pa).filled(:int?, gteq?: 0, lt?: (2**32)/2)
  required(:cycle).value(included_in?: Contract::Payment.cycles.values)
  # tariff that should be used to calculate the price
  optional(:tariff_id).filled(:int?)
  optional(:price_cents).maybe(:int?, gteq?: 0, lt?: (2**32)/2)

  rule(price_cents: [:tariff_id, :price_cents]) do |tariff_id, price_cents|
    tariff_id.filled?.not.then(price_cents.filled?)#.and(price_cents.value(:int?, gt?: 0)))
  end
end
