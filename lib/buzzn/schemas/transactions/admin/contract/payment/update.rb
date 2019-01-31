require_relative '../payment'

Schemas::Transactions::Admin::Contract::Payment::Update = Schemas::Support.Form(Schemas::Transactions::Update) do
  optional(:begin_date).filled(:date?)
  optional(:price_cents).filled(:int?, gteq?: 0, lt?: (2**32)/2)
  optional(:energy_consumption_kwh_pa).filled(:int?, gteq?: 0, lt?: (2**32)/2)
  optional(:cycle).value(included_in?: Contract::Payment.cycles.values)
end
