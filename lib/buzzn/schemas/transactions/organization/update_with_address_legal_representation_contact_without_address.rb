require_relative 'update'
require_relative '../address/update'

module Schemas::Transactions::Organization

  UpdateWithAddressLegalRepresentationContactWithoutAddress = Schemas::Support.Form(Update) do
    optional(:address).schema(Schemas::Transactions::Address::Update)
    optional(:contract).schema(Schemas::Transactions::Person::UpdateWithoutAddress)
    optional(:legal_representation).schema(Schemas::Transactions::Person::Update)
  end

end
