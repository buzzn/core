require_relative '../localpool_gap_contract'
require_relative '../common'

module Schemas::Transactions

  Admin::Contract::Localpool::GapContract::Create = Schemas::Support.Form(Schemas::Transactions::Admin::Contract::Common) do
    required(:begin_date).maybe(:date?)
    optional(:share_register_with_group).filled(:bool?)
    optional(:share_register_publicly).filled(:bool?)
    required(:register_meta).schema do
      required(:id).filled
    end
  end

end
