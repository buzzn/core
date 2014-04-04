Fabricator :address do
  address     { Faker::AddressDE.street_address }
  street      { Faker::AddressDE.street_address }
  zip         { Faker::AddressDE.zip_code }
  city        { Faker::AddressDE.city }
  state       { Faker::AddressDE.state }
  country     { Faker::AddressDE.country }
end