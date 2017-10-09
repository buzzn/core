FactoryGirl.define do
  factory :person do
    first_name          { FFaker::NameDE.first_name }
    last_name           { FFaker::NameDE.last_name }
    email               { "dev+#{first_name.downcase}.#{last_name.downcase}@buzzn.net" }
    phone               { FFaker::PhoneNumberDE.phone_number }
    prefix              Person.prefixes[:male]
    preferred_language  Person.preferred_languages[:german]
    address

    trait :wolfgang do
      title             'Dr.'
      first_name        'Wolfgang'
      last_name         'Owner'
    end

    trait :organization_contact do
      first_name 'Karl'
      last_name  'Kontakt'
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

    # Image is not added by default because the uploader creates a bunch of variations/resizes,
    # significantly slowing down the factory.
    trait :with_image do
      image { File.new(Rails.root.join('db/seed_assets/profiles', generate(:person_image))) }
    end
  end
end