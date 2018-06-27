require_relative 'create'
require_relative '../../constraints/address'

module Schemas::Transactions::Person

  CreateWithAddress = Schemas::Support.Form(Create) do
    optional(:address).schema(Schemas::Constraints::Address)
  end

end
