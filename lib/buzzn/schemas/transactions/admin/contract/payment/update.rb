require_relative '../payment'

Schemas::Transactions::Admin::Contract::Payment::Update = Schemas::Support.Form(Schemas::Transactions::Update) do
  optional(:begin_date).filled(:date?)
  optional(:price_cents).filled(:int?, gt?: 0)
  optional(:energy_consumption_kwh_pa).filled(:int?, gt?: 0)
  optional(:cycle).value(included_in?: Contract::Payment.cycles.values)
end
