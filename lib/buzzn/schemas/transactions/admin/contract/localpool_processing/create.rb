require_relative '../localpool_processing'
require_relative '../base'

Schemas::Transactions::Admin::Contract::Localpool::Processing::Create = Schemas::Support.Form(Schemas::Transactions::Admin::Contract::Base) do
  required(:begin_date).filled(:date?)
  required(:tax_number).filled(:str?, max_size?: 64)
end
