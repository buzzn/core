require_relative '../../constraints/organization/base'
require_relative '../organization'
require_relative '../address/create'
require_relative '../person/create'

module Schemas::Transactions::Organization

  Create = Schemas::Constraints::Organization::Base

  CreateWithNested = Schemas::Support.Form(Create) do

    optional(:address).schema(Schemas::Transactions::Address::Create)
    optional(:contact) do
      id?.not.then(schema(Schemas::Transactions::Person::AssignOrCreateWithAddress))
    end
    optional(:legal_representation) do
      id?.not.then(schema(Schemas::Transactions::Person::AssignOrCreateWithAddress))
    end
  end

  AssignOrCreateWithNested = Schemas::Support.Form(CreateWithNested) do
    optional(:id).value(:int?)
  end

end
