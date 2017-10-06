FactoryGirl.define do
  factory :organization do
    sequence(:name)  { |i| "Generic organization #{i}" }
    description      "Description of the generic organization"
    mode             Organization.modes.first
    email            "dev+generic-organization@buzzn.net"
    edifactemail     "dev+generic-organization-edifact@buzzn.net"
    phone            "089 / 32 16 8"
    website          "www.generic-organization.com"
    contact          { FactoryGirl.create(:person, first_name: "Otto", last_name: "Organisator") }
  end
end