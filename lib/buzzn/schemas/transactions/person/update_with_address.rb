require_relative 'update'
require_relative '../address/update'

module Schemas::Transactions::Person

  UpdateWithAddress = Schemas::Support.Form(Update) do
    optional(:address).schema(Schemas::Transactions::Address::Update)
  end

end
