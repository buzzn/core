require_relative 'resource'
Buzzn::Transaction.define do |t|
  t.register_validation(:create_person_schema) do
    optional(:title).filled(:str?, max_size?: 64)
    required(:prefix).value(included_in?: Person::PREFIXES)
    required(:first_name).filled(:str?, max_size?: 64)
    required(:last_name).filled(:str?, max_size?: 64)
    required(:email).filled(:str?, :email?, max_size?: 64)
    optional(:phone).filled(:str?, :phone_number?, max_size?: 64)
    optional(:fax).filled(:str?, :phone_number?, max_size?: 64)
    required(:preferred_language).value(included_in?: Person::PREFERRED_LANGUAGES)   
  end

  t.register_validation(:update_person_schema) do
    optional(:name).filled(:str?)
    optional(:begin_date).filled(:date?)
    optional(:end_date).filled(:date?)
  end

  t.define(:update_person) do
    validate :update_person_schema
    step :resource, with: :update_resource
  end
end
