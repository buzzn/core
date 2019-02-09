require_relative '../localpool_gap_contracts'
require_relative '../common'

module Schemas::Transactions

  Admin::Contract::Localpool::GapContracts::Create = Schemas::Support.Form(Schemas::Transactions::Admin::Contract::Common) do
    required(:begin_date).filled(:date?)
    required(:last_date).filled(:date?)
    optional(:share_register_with_group).filled(:bool?)
    optional(:share_register_publicly).filled(:bool?)
  end

end
