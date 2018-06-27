require_relative 'create'
require_relative '../address/create'
require_relative '../person/create_with_address'

module Schemas::Transactions::Organization

  CreateWithNested = Schemas::Support.Form(Create) do
    optional(:address).schema(Schemas::Transactions::Address::Create)
    optional(:contact).schema(Schemas::Transactions::Person::CreateWithAddress)
    optional(:legal_representation).schema(Schemas::Transactions::Person::Create)
  end

end
