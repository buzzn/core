Fabricator :address do
  i = 1
  street_name   { Faker::AddressDE.street_name }
  street_number { i += 1 }
  zip           { 25679 + i }
  city          { Faker::AddressDE.city }
  state         { Faker::AddressDE.state }
  country       { Faker::AddressDE.country }
  time_zone     'Berlin'
end

Fabricator :address_hopf, from: :address do
  street_name   { "Hopfstraße" }
  street_number { 24 }
  zip           { 66666 }
  city          { "Hopfstadt" }
  state         { "Bayern" }
  country       { "Deutschland" }
  time_zone     'Berlin'
end