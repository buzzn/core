FactoryGirl.define do
  factory :address do
    street  { FFaker::AddressDE.street_address }
    city    { FFaker::AddressDE.city }
    zip     { FFaker::AddressDE.zip_code }
    country Address.countries[:germany]
  end
end
