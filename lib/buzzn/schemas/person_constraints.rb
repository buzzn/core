require_relative 'support/form'
PersonContraints = Buzzn::Schemas.Form do
  required(:prefix).value(included_in?: Person.prefixes.values)
  required(:first_name).filled(:str?, max_size?: 64)
  required(:last_name).filled(:str?, max_size?: 64)
  required(:email).filled(:str?, :email?, max_size?: 64)
  required(:preferred_language).value(included_in?: Person.preferred_languages.values)
  optional(:title).value(included_in?: Person.titles.values)
  optional(:phone).filled(:str?, :phone_number?, max_size?: 64)
  optional(:fax).filled(:str?, :phone_number?, max_size?: 64)
end
