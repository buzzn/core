require_relative '../../constraints/organization/base'
require_relative '../organization'
require_relative '../address/create'
require_relative '../person/create'

module Schemas::Transactions::Organization

  Create = Schemas::Constraints::Organization::Base

  CreateWithNested = Schemas::Support.Form(Create) do
    optional(:address).schema(Schemas::Transactions::Address::Create)
    optional(:contact).schema(Schemas::Transactions::Person::CreateWithAddress)
    optional(:legal_representation).schema(Schemas::Transactions::Person::Create)
  end

end
