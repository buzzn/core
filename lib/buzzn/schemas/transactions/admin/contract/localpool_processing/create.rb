require_relative '../localpool_processing'
require_relative '../base'

Schemas::Transactions::Admin::Contract::Localpool::Processing::Create = Schemas::Support.Form(Schemas::Transactions::Admin::Contract::Base) do
  required(:begin_date).filled(:date?)
  optional(:tax_number).filled(:str?, max_size?: 64)
  optional(:sales_tax_number).filled(:str?, max_size?: 64)
  optional(:creditor_identification).filled(:str?, max_size?: 64)
end
