# encoding: utf-8

Fabricator :user do
  email       { Faker::Internet.email }
  first_name  { Faker::Name.first_name }
  last_name   { Faker::Name.last_name }
  street      { Faker::AddressDE.street_address }
  zip         { Faker::AddressDE.zip_code }
  city        { Faker::AddressDE.city }
  country     { Faker::AddressDE.country }
  phone       { Faker::PhoneNumber.phone_number }
  terms       true
  password    'testtest'
  after_create { |user | user.confirm! }
end

Fabricator :admin, from: :user do
  email       'admin@buzzn.net'
end
