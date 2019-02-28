require_relative '../localpool_third_party'
require_relative '../../register/update_meta'

module Schemas::Transactions::Admin::Contract::Localpool::ThirdParty

  Update = Schemas::Support.Form(Schemas::Transactions::Update) do
    optional(:signing_date).maybe(:date?)
    optional(:begin_date).maybe(:date?)
    optional(:termination_date).maybe(:date?)
    optional(:last_date).maybe(:date?)

    optional(:third_party_billing_number).filled(:str?)
    optional(:third_party_renter_number).filled(:str?)
    optional(:share_register_with_group).value(:bool?)
    optional(:share_register_publicly).value(:bool?)

    optional(:register_meta) do
      schema(Schemas::Transactions::Admin::Register::UpdateMeta)
    end
  end

end
