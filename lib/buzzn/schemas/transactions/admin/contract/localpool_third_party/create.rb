require_relative '../base'
require_relative '../../register/create_meta'
require_relative '../localpool_third_party'

module Schemas::Transactions::Admin::Contract::Localpool::ThirdParty

  Create = Schemas::Support.Form(Schemas::Transactions::Admin::Contract::Base) do
    required(:begin_date).maybe(:date?)
    optional(:share_register_with_group).filled(:bool?)
    optional(:share_register_publicly).filled(:bool?)
    optional(:third_party_billing_number).filled(:str?)
    optional(:third_party_renter_number).filled(:str?)
    required(:register_meta) do
      schema(Schemas::Transactions::Admin::Register::CreateMetaLoose)
    end
  end

end
