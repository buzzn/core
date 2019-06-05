require_relative '../market_function'
require_relative '../address/create'
require_relative '../address/update'
require_relative '../person/create'
require_relative '../person/update'
require_relative '../../../../../app/models/organization/market_function'

module Schemas::Transactions::MarketFunction

  UpdateBase = Schemas::Support.Form(Schemas::Transactions::Update) do
    optional(:market_partner_id).filled(:str?, max_size?: 64)
    optional(:edifact_email).filled(:str?, :email?, max_size?: 64)
  end

  Update = Schemas::Support.Form(UpdateBase) do
    optional(:function).value(included_in?: ::Organization::MarketFunction.functions.values)
  end

  class << self

    def update_for(resource, organization)
      schema = if resource.address.nil?
                 Schemas::Support.Form(UpdateBase) do
                   optional(:address).schema(Schemas::Transactions::Address::Create)
                 end
               else
                 Schemas::Support.Form(UpdateBase) do
                   optional(:address).schema(Schemas::Transactions::Address::Update)
                 end
               end
      schema = if resource.contact_person.nil?
                 Schemas::Support.Form(schema) do
                   optional(:contact_person) do
                     id?.not.then(schema(Schemas::Transactions::Person::AssignOrCreateWithAddress))
                   end
                 end
               elsif resource.contact_person.address.nil?
                 Schemas::Support.Form(schema) do
                   optional(:contact_person) do
                     schema(Schemas::Transactions::Person.assign_or_update_without_address)
                   end
                 end
               else
                 Schemas::Support.Form(schema) do
                   optional(:contact_person) do
                     schema(Schemas::Transactions::Person.assign_or_update_with_address)
                   end
                 end
               end
      functions = organization.market_functions.collect { |x| x.function }
      possible_functions = ::Organization::MarketFunction.functions.values - functions
      schema = Schemas::Support.Form(schema) do
        optional(:function).value(included_in?: possible_functions)
      end
      schema
    end

  end

end
