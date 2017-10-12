FactoryGirl.define do
  factory :organization do
    name             { generate(:organization_name) }
    description      "Description of the generic organization"
    mode             Organization.modes.first
    email            "dev+generic-organization@buzzn.net"
    edifactemail     "dev+generic-organization-edifact@buzzn.net"
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
      mode :other
    end

    trait :contracting_party do
      with_bank_account
      with_address
    end

    trait :transmission_system_operator do
      contracting_party
      mode :transmission_system_operator
    end

    trait :distribution_system_operator do
      contracting_party
      mode :distribution_system_operator
    end

    trait :electricity_supplier do
      contracting_party
      mode :electricity_supplier
    end

    trait :metering_point_operator do
      contracting_party
      mode :metering_point_operator
    end
  end
end
