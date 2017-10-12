FactoryGirl.define do
  factory :person do
    transient do
      roles {}
    end
    first_name          { FFaker::NameDE.first_name }
    last_name           { FFaker::NameDE.last_name }
    email do
      first = first_name.downcase.gsub(/[^0-9a-z]/, '')
      last  = last_name.downcase.gsub(/[^0-9a-z]/, '')
      "dev+#{first}.#{last}@buzzn.net"
    end
    phone               { FFaker::PhoneNumberDE.phone_number }
    prefix              Person.prefixes[:male]
    preferred_language  Person.preferred_languages[:german]
    address

    after(:create) do |person, evaluator|
      evaluator.roles.each { |role, resource| person.add_role(role, resource) } if evaluator.roles
    end

    # All group owners seem to be called Wolfgang, so we dedicate a trait to him.
    trait :wolfgang do
      title      'Dr.'
      first_name 'Wolfgang'
      last_name  'Owner'
    end

    trait :organization_contact do
      last_name  'Kontakt'
    end

    trait :with_bank_account do
      after(:create) do |person|
        person.bank_accounts = [ FactoryGirl.create(:bank_account, contracting_party: person) ]
      end
    end

    trait :powertaker do
      last_name { generate(:powertaker_last_name) }
      email     { generate(:powertaker_email) }
    end

    trait :with_self_role do
      after(:create) { |person| person.add_role(Role::SELF, person) }
    end

    trait :with_account do
      after(:create) { |person| create(:account, person: person) }
    end

    # Image is not added by default because the uploader creates a bunch of variations/resizes,
    # significantly slowing down the factory.
    trait :with_image do
      image { File.new(Rails.root.join('db/seed_assets/profiles', generate(:person_image))) }
    end
  end
end
