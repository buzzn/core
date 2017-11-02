require_relative '../person'

Schemas::Transactions::Person::Update = Buzzn::Schemas.Form(Schemas::Transactions::Update) do
  optional(:title).value(included_in?: ::Person.titles.values)
  optional(:prefix).value(included_in?: ::Person.prefixes.values)
  optional(:first_name).filled(:str?, max_size?: 64)
  optional(:last_name).filled(:str?, max_size?: 64)
  optional(:phone).filled(:str?, :phone_number?, max_size?: 64)
  optional(:fax).filled(:str?, :phone_number?, max_size?: 64)
  optional(:preferred_language).value(included_in?: ::Person.preferred_languages.values)
end
