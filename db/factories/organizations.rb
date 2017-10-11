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
  end
end
