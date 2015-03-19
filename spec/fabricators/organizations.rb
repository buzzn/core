Fabricator :organization do
  name        { FFaker::Company.name }
  phone       { FFaker::PhoneNumber.phone_number }
  fax         { FFaker::PhoneNumber.phone_number }
  email       { FFaker::Internet.email }
  description { FFaker::Company.catch_phrase }
  website     { "http://www.#{FFaker::Internet.domain_name}" }
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

Fabricator :metering_point_operator, from: :organization do
  mode 'metering_point_operator'
end

Fabricator :transmission_system_operator, from: :organization do
  mode 'transmission_system_operator'
end