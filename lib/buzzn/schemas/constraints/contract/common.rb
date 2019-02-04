require_relative 'base'

Schemas::Constraints::Contract::Common = Schemas::Support.Form(Schemas::Constraints::Contract::Base) do
  optional(:contract_number).filled(:int?)
  optional(:contract_number_addition).filled(:int?)

  optional(:renewable_energy_law_taxation).value(included_in?: Contract::Base.renewable_energy_law_taxations.values)

  optional(:forecast_kwh_pa).filled(:int?)

  optional(:original_signing_user).filled(:str?)
  optional(:mandate_reference).filled(:str?)

  optional(:confirm_pricing_model).filled(:bool?)
  optional(:power_of_attorney ).filled(:bool?)
  optional(:other_contract).filled(:bool?)
  optional(:move_in).filled(:bool?)
  optional(:authorization).filled(:bool?)

  optional(:third_party_billing_number).filled(:str?)
  optional(:third_party_renter_number).filled(:str?)
  optional(:metering_point_operator_name).filled(:str?)
  optional(:old_supplier_name).filled(:str?)
  optional(:old_customer_number).filled(:str?)
  optional(:old_account_number).filled(:str?)

  optional(:energy_consumption_before_kwh_pa).value(:int?, gt?: 0)
end
