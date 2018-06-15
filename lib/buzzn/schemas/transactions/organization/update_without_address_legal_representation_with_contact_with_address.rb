require_relative 'update'
require_relative '../address/update'

module Schemas::Transactions::Organization

  UpdateWithAddressLegalRepresentationContactWithAddress = Schemas::Support.Form(Update) do
    optional(:address).schema(Schemas::Transactions::Address::Create)
    optional(:contract).schema(Schemas::Transactions::Person::UpdateWithAddress)
    optional(:legal_representation).schema(Schemas::Transactions::Person::Create)
  end

end
