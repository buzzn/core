require_relative '../market_function'
require_relative '../address/create'
require_relative '../person/create'
require_relative '../../../../../app/models/organization/market_function'

module Schemas::Transactions::MarketFunction

  CreateBase = Schemas::Support.Schema do
    required(:market_partner_id).filled(:str?, max_size?: 64)
    required(:edifact_email).filled(:str?, :email?, max_size?: 64)

    optional(:contact_person) do
      id?.not.then(schema(Schemas::Transactions::Person::AssignOrCreateWithAddress))
    end

    optional(:address).schema(Schemas::Transactions::Address::Create)
  end

  Create = Schemas::Support.Form(CreateBase) do
    required(:function).value(included_in?: ::Organization::MarketFunction.functions.values)
  end

  class << self

    def create_for(organization)
      functions = organization.market_functions.collect { |x| x.function }
      possible_functions = ::Organization::MarketFunction.functions.values - functions
      Schemas::Support.Form(CreateBase) do
        required(:function).value(included_in?: possible_functions)
      end
    end

  end

end
