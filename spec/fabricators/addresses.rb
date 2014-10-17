Fabricator :address do
  i = 1
  street_name   { Faker::AddressDE.street_name }
  street_number { i += 1 }
  zip           { Faker::AddressDE.zip_code }
  city          { Faker::AddressDE.city }
  state         { Faker::AddressDE.state }
  country       { Faker::AddressDE.country }
  time_zone     'Berlin'
end