Fabricator :organization do
  name        { Faker::Company.name }
  phone       { Faker::PhoneNumber.phone_number }
  fax         { Faker::PhoneNumber.phone_number }
  email       { Faker::Internet.email }
  description { Faker::Company.catch_phrase }
  website     { "http://www.#{Faker::Internet.domain_name}" }
  address     { Fabricate(:address) }
end

Fabricator :discovergy, from: :organization do
  name    'Discovergy'
end