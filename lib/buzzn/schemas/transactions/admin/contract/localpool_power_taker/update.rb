require_relative '../localpool_power_taker'
require_relative '../../register/update_meta'

module Schemas::Transactions

  Admin::Contract::Localpool::PowerTaker::Update = Schemas::Support.Form(Schemas::Transactions::Update) do

    optional(:signing_date).maybe(:date?)
    optional(:begin_date).maybe(:date?)
    optional(:termination_date).maybe(:date?)
    optional(:end_date).maybe(:date?)

    optional(:register_meta) do
      schema(Admin::Register::UpdateMeta)
    end
  end

end
