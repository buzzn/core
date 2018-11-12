require_relative '../localpool_power_taker'
require_relative '../../register/update_meta'

module Schemas::Transactions

  Admin::Contract::Localpool::PowerTaker::Update = Schemas::Support.Form(Schemas::Transactions::Update) do

    optional(:signing_date).maybe(:date?)
    optional(:begin_date).maybe(:date?)
    optional(:termination_date).maybe(:date?)
    optional(:end_date).maybe(:date?)

    optional(:forecast_kwh_pa).filled(:int?)

    optional(:original_signing_user).maybe(:str?)
    optional(:mandate_reference).maybe(:str?)

    optional(:confirm_pricing_model).filled(:bool?)
    optional(:power_of_attorney).filled(:bool?)
    optional(:other_contract).filled(:bool?)
    optional(:move_in).filled(:bool?)
    optional(:authorization).filled(:bool?)

    optional(:third_party_billing_number).maybe(:str?)
    optional(:third_party_renter_number).maybe(:str?)
    optional(:metering_point_operator_name).maybe(:str?)
    optional(:old_supplier_name).maybe(:str?)
    optional(:old_customer_number).maybe(:str?)
    optional(:old_account_number).maybe(:str?)

    optional(:register_meta) do
      schema(Admin::Register::UpdateMeta)
    end

    optional(:share_register_with_group).value(:bool?)
    optional(:share_register_publicly).value(:bool?)
  end

end
