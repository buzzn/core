FactoryGirl.define do
  factory :person do
    first_name          { FFaker::NameDE.first_name }
    last_name           { FFaker::NameDE.last_name }
    email               { |attrs| "dev+#{attrs[:first_name].downcase}#{attrs[:last_name].downcase}@buzzn.net" }
    phone               { FFaker::PhoneNumberDE.phone_number }
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

    trait :with_bank_account do
      before(:create) do |person|
        person.bank_accounts = [ FactoryGirl.create(:bank_account) ]
      end
    end

    trait :powertaker do
      last_name { generate(:powertaker_last_name) }
      email     { generate(:powertaker_email) }
    end
  end
end