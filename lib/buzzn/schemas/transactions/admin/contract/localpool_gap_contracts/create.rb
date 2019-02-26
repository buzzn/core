require_relative '../localpool_gap_contracts'
require_relative '../common'

module Schemas::Transactions

  Admin::Contract::Localpool::GapContracts::Create = Schemas::Support.Form(Schemas::Transactions::Admin::Contract::Common) do
    required(:last_date).filled(:date?)
    optional(:begin_date).filled(:date?) # will be localpool.next_billing_cycle_begin_date
    optional(:share_register_with_group).filled(:bool?)
    optional(:share_register_publicly).filled(:bool?)
  end

end
