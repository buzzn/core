require_relative '../../constraints/organization/base'
require_relative '../organization'
require_relative '../address/create'
require_relative '../person/create'
require_relative '../market_function/create'

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

  CreateMarketWithNested = Schemas::Support.Form do
    required(:name).filled(:str?, max_size?: 64, min_size?: 4)
    optional(:description).maybe(:str?, max_size?: 256)
    optional(:email).maybe(:str?, :email?, max_size?: 64)
    optional(:phone).maybe(:str?, :phone_number?, max_size?: 64)
    optional(:fax).maybe(:str?, :phone_number?, max_size?: 64)
    optional(:website).maybe(:str?, :url?, max_size?: 64)

    optional(:address).schema(Schemas::Transactions::Address::Create)

    required(:functions).filled { each(Schemas::Transactions::MarketFunction::Create) }
  end

  AssignOrCreateWithNested = Schemas::Support.Form(CreateWithNested) do
    optional(:id).value(:int?)
  end

end
