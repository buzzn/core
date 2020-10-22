require './app/models/person.rb'
require_relative '../person'
require_relative '../address/nested'

module Schemas::Transactions::Person

  extend Schemas::Transactions::Address::Nested

  Update = Schemas::Support.Form(Schemas::Transactions::Update) do
    optional(:prefix).value(included_in?: ::Person.prefixes.values)
    optional(:first_name).filled(:str?, max_size?: 64)
    optional(:last_name).filled(:str?, max_size?: 64)
    optional(:email).maybe(:str?, max_size?: 64)
    optional(:preferred_language).value(included_in?: [nil] + ::Person.preferred_languages.values)
    optional(:title).value(included_in?: [nil] + ::Person.titles.values)
    optional(:phone).maybe(:filled?, :str?, :phone_number?, max_size?: 64)
    optional(:fax).maybe(:filled?, :str?, :phone_number?, max_size?: 64)
    optional(:email_backend_host).maybe(:filled?, :str?, max_size?: 128)
    optional(:email_backend_port).maybe(:filled?, :int?)
    optional(:email_backend_user).maybe(:filled?, :str?, max_size?: 128)
    optional(:email_backend_password).maybe(:filled?, :str?, max_size?: 128)
    optional(:email_backend_encryption).maybe(:filled?, :str?, max_size?: 16)
    optional(:email_backend_encryption).maybe(:filled?, :bool?)
  end

  AssignOrUpdate = Schemas::Support.Form(Schemas::Transactions::UpdateOptional) do
    optional(:id).filled(:int?)
    optional(:prefix).value(included_in?: ::Person.prefixes.values)
    optional(:first_name).filled(:str?, max_size?: 64)
    optional(:last_name).filled(:str?, max_size?: 64)
    optional(:email).maybe(:str?, max_size?: 64)
    optional(:preferred_language).value(included_in?: [nil] + ::Person.preferred_languages.values)
    optional(:title).value(included_in?: [nil] + ::Person.titles.values)
    optional(:phone).maybe(:filled?, :str?, :phone_number?, max_size?: 64)
    optional(:fax).maybe(:filled?, :str?, :phone_number?, max_size?: 64)
    optional(:email_backend_host).maybe(:filled?, :str?, max_size?: 128)
    optional(:email_backend_port).maybe(:filled?, :int?)
    optional(:email_backend_user).maybe(:filled?, :str?, max_size?: 128)
    optional(:email_backend_password).maybe(:filled?, :str?, max_size?: 128)
    optional(:email_backend_encryption).maybe(:filled?, :str?, max_size?: 16)
    optional(:email_backend_encryption).maybe(:filled?, :bool?)
  end

  Assign = Schemas::Support.Form do
    required(:id).filled(:int?)
  end

end
