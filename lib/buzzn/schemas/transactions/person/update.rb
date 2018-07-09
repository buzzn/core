require './app/models/person.rb'
require_relative '../person'
require_relative '../address/nested'

module Schemas::Transactions::Person

  extend Schemas::Transactions::Address::Nested

  Update = Schemas::Support.Form(Schemas::Transactions::Update) do
    optional(:title).value(included_in?: ::Person.titles.values)
    optional(:prefix).value(included_in?: ::Person.prefixes.values)
    optional(:first_name).filled(:str?, max_size?: 64)
    optional(:last_name).filled(:str?, max_size?: 64)
    optional(:phone).filled(:str?, :phone_number?, max_size?: 64)
    optional(:fax).filled(:str?, :phone_number?, max_size?: 64)
    optional(:preferred_language).value(included_in?: ::Person.preferred_languages.values)
  end

  AssignOrUpdate = Schemas::Support.Form(Update) do
    optional(:id).filled(:int?)
  end

end
