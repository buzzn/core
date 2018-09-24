require_relative '../../constraints/person'
require_relative '../../constraints/address'
require_relative '../person'

module Schemas::Transactions::Person

  Create = Schemas::Constraints::Person

  CreateWithAddress = Schemas::Support.Form(Create) do
    optional(:address).schema(Schemas::Constraints::Address)
  end

  AssignOrCreate = Schemas::Support.Form(Create) do
    optional(:id).value(:int?)
  end

  AssignOrCreateWithAddressOptional = Schemas::Support.Form do
    optional(:prefix).value(included_in?: Person.prefixes.values)
    optional(:first_name).maybe(:str?, max_size?: 64)
    optional(:last_name).maybe(:str?, max_size?: 64)
    optional(:email).maybe(:str?, :email?, max_size?: 64)
    optional(:preferred_language).value(included_in?: Person.preferred_languages.values)
    optional(:title).value(included_in?: Person.titles.values)
    optional(:phone).maybe(:str?, :phone_number?, max_size?: 64)
    optional(:fax).maybe(:str?, :phone_number?, max_size?: 64)
    optional(:id).value(:int?)
    optional(:address).schema(Schemas::Constraints::Address)
  end

  AssignOrCreateWithAddress = Schemas::Support.Form(CreateWithAddress) do
    optional(:id).value(:int?)
  end

end
