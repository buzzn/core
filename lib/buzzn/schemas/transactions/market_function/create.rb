require_relative '../market_function'
require_relative '../address/create'
require_relative '../person/create'
require_relative '../../../../../app/models/organization/market_function'

module Schemas::Transactions::MarketFunction

  Create = Schemas::Support.Schema do
    required(:market_partner_id).filled(:str?, max_size?: 64)
    required(:edifact_email).filled(:str?, :email?, max_size?: 64)
    required(:function).value(included_in?: ::Organization::MarketFunction.functions.values)

    optional(:contact_person) do
      id?.not.then(schema(Schemas::Transactions::Person::AssignOrCreateWithAddress))
    end

    optional(:address).schema(Schemas::Transactions::Address::Create)
  end

end
