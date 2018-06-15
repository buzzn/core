require_relative 'update'
require_relative '../address/create'

module Schemas::Transactions::Organization

  UpdateWithoutAddressLegalRepresentationContact = Schemas::Support.Form(Update) do
    optional(:address).schema(Schemas::Transactions::Address::Create)
    optional(:contact).schema(Schemas::Transactions::Person::CreateWithAddress)
    optional(:legal_representation).schema(Schemas::Transactions::Person::Create)
  end

end
