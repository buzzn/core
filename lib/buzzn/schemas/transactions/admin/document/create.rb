require_relative '../../document/create'
require_relative '../document'

Schemas::Transactions::Admin::Document::Create = Schemas::Support.Form do
  required(:file).schema(Schemas::Transactions::Document::Create)
end
