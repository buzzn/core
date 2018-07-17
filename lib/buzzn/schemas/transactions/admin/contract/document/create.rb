require_relative '../document'
require_relative '../../../document/create'

Schemas::Transactions::Admin::Contract::Document::Create = Schemas::Support.Form do
  required(:file).schema(Schemas::Transactions::Document::Create)
end
