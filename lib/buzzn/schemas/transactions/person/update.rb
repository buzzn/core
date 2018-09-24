require './app/models/person.rb'
require_relative '../person'
require_relative '../address/nested'

module Schemas::Transactions::Person

  extend Schemas::Transactions::Address::Nested

  Update = Schemas::Support.Form(Schemas::Transactions::Update) do
    optional(:prefix).value(included_in?: ::Person.prefixes.values)
    optional(:first_name).filled(:str?, max_size?: 64)
    optional(:last_name).filled(:str?, max_size?: 64)
    optional(:email).filled(:str?, max_size?: 64)
    optional(:preferred_language).value(included_in?: [nil] + ::Person.preferred_languages.values)
    optional(:title).value(included_in?: [nil] + ::Person.titles.values)
    optional(:phone).maybe(:filled?, :str?, :phone_number?, max_size?: 64)
    optional(:fax).maybe(:filled?, :str?, :phone_number?, max_size?: 64)
  end

  AssignOrUpdate = Schemas::Support.Form(Schemas::Transactions::UpdateOptional) do
    optional(:id).filled(:int?)
    optional(:prefix).value(included_in?: ::Person.prefixes.values)
    optional(:first_name).filled(:str?, max_size?: 64)
    optional(:last_name).filled(:str?, max_size?: 64)
    optional(:email).filled(:str?, max_size?: 64)
    optional(:preferred_language).value(included_in?: [nil] + ::Person.preferred_languages.values)
    optional(:title).value(included_in?: [nil] + ::Person.titles.values)
    optional(:phone).maybe(:filled?, :str?, :phone_number?, max_size?: 64)
    optional(:fax).maybe(:filled?, :str?, :phone_number?, max_size?: 64)
  end

  Assign = Schemas::Support.Form do
    required(:id).filled(:int?)
  end

end
