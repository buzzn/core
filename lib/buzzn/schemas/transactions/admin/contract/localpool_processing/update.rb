require_relative '../localpool_processing'

module Schemas::Transactions::Admin::Contract::LocalpoolProcessing

  Update = Schemas::Support.Form(Schemas::Transactions::Update) do
    optional(:tax_number).filled(:str?, max_size?: 64)
    optional(:signing_date).filled(:date?)
    optional(:begin_date).maybe(:date?)
    optional(:termination_date).maybe(:date?)
    optional(:end_date).maybe(:date?)
    # FIXME add rest of tax details
  end

end
