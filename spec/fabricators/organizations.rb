# coding: utf-8
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


Fabricator :transmission_system_operator_with_address, from: :transmission_system_operator do
  address     { Fabricate(:address, street_name: 'Zu den Höfen', street_number: '7', zip: 37181, city: 'Asche', state: 'Lower Saxony') }
end

Fabricator :electricity_supplier_with_contracts, from: :electricity_supplier do
  contracts   { [ Fabricate(:electricity_supplier_contract)] }
end

Fabricator :metering_service_provider_with_contracting_party, from: :metering_service_provider do
  after_create do |organization|
    organization.update contracting_party: Fabricate(:contracting_party, legal_entity: 'company', organization: organization)
  end
end

# needed for groups fabricator
Fabricator :buzzn_metering, from: :metering_service_provider do
  name 'buzzn-metering'
  mode 'metering_service_provider'
end

# needed for contracts fabricator
Fabricator :discovergy, from: :metering_service_provider do
  name 'discovergy'
  mode 'metering_service_provider'
end

# needed for contracts fabricator
Fabricator :mysmartgrid, from: :metering_service_provider do
  name 'mysmartgrid'
  mode 'metering_service_provider'
end
