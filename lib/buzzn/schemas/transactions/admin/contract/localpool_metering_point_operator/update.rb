require_relative '../localpool_processing'

module Schemas::Transactions::Admin::Contract::Localpool::MeteringPointOperator

  Update = Schemas::Support.Form(Schemas::Transactions::Update) do
    optional(:signing_date).filled(:date?)
    optional(:begin_date).maybe(:date?)
    optional(:termination_date).maybe(:date?)
    optional(:end_date).maybe(:date?)
  end

end
