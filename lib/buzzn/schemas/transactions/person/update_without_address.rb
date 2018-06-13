require_relative 'update'
require_relative '../address/create'

module Schemas::Transactions::Person

  UpdateWithoutAddress = Schemas::Support.Form(Update) do
    optional(:address).schema(Schemas::Transactions::Address::Create)
  end

end
