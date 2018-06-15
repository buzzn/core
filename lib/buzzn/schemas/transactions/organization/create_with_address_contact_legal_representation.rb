require_relative 'create'
require_relative '../../constraints/address'

module Schemas::Transactions::Organization

  CreateWithAddressLegalRepresentationContact = Schemas::Support.Form(Create) do
    optional(:address).schema(Schemas::Constraints::Address)
    optional(:contact).schema(Schemas::Transactions::Person::CreateWithAddress)
    optional(:legal_representation).schema(Schemas::Transactions::Person::Create)
  end

end
