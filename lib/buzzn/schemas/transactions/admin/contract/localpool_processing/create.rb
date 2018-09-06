require_relative '../localpool_processing'
require_relative '../../../../constraints/contract/base'

Schemas::Transactions::Admin::Contract::Localpool::Processing::Create = Schemas::Support.Form(Schemas::Constraints::Contract::Base) do
  required(:tax_number).filled(:str?, max_size?: 64)
end
