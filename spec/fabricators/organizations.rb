Fabricator :organization do
  name        { Faker::Company.name }
  phone       { Faker::PhoneNumber.phone_number }
  fax         { Faker::PhoneNumber.phone_number }
  email       { Faker::Internet.email }
  description { Faker::Company.catch_phrase }
  website     { "http://www.#{Faker::Internet.domain_name}" }
  address     { Fabricate(:address) }
end


Fabricator :distribution_system_operator, from: :organization do
  mode 'distribution_system_operator'
end

Fabricator :electricity_supplier, from: :organization do
  mode 'electricity_supplier'
end

Fabricator :metering_service_provider, from: :organization do
  mode 'metering_service_provider'
end
