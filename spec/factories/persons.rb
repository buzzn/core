FactoryGirl.define do
  factory :person do
    first_name          "Uwe"
    last_name           "User"
    email               "dev+uweuser@buzzn.net"
    phone               "0815 123 456 789"
    prefix              Person.prefixes[:male]
    preferred_language  Person.preferred_languages[:german]
    address

    trait :wolfgang do
      first_name        "Wolfgang"
      last_name         "Wolf"
      email             "dev+wolfgang@buzzn.net"
    end

    trait :organization_contact do
      first_name "Karl"
      last_name  "Kontakt"
      email      "dev+karl@buzzn.net"
    end
  end
end