FactoryGirl.define do
  factory :address do
    street  { FFaker::AddressDE.street_address }
    city    { FFaker::AddressDE.city }
    zip     { FFaker::AddressDE.zip_code }
    state   { Address.states.keys.sample }
    country Address.countries[:germany]
  end
end