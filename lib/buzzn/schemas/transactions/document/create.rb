require_relative '../document'

Schemas::Transactions::Document::Create = Schemas::Support.Schema do
  required(:filename).filled(:str?)
  required(:tempfile).filled
end
