FactoryGirl.define do
  factory :organization do
    name             { generate(:organization_name) }
    description      "Description of the generic organization"
    email            "dev+generic-organization@buzzn.net"
    phone            "089 / 32 16 8"
    website          "www.generic-organization.com"
    contact          { FactoryGirl.create(:person, :organization_contact) }

    trait :with_bank_account do
      after(:create) do |organization|
        organization.bank_accounts = [ FactoryGirl.create(:bank_account, contracting_party: organization) ]
      end
    end

    trait :with_address do
      address
    end

    trait :other do
    end

    trait :contracting_party do
      with_bank_account
      with_address
    end

    trait :transmission_system_operator do
      contracting_party
    end

    trait :distribution_system_operator do
      contracting_party
    end

    trait :electricity_supplier do
      contracting_party
    end

    trait :metering_point_operator do
      contracting_party
    end
  end
end
