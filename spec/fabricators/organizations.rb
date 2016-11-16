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

Fabricator :power_giver, from: :organization do
  mode 'power_giver'
end

Fabricator :electricity_supplier, from: :organization do
  mode 'electricity_supplier'
end

Fabricator :metering_service_provider, from: :organization do
  mode 'metering_service_provider'
end

Fabricator :register_operator, from: :organization do
  mode 'register_operator'
end

Fabricator :transmission_system_operator, from: :organization do
  mode 'transmission_system_operator'
end

Fabricator :transmission_system_operator_with_address, from: :transmission_system_operator do
  address     { Fabricate(:address, street_name: 'Zu den Höfen', street_number: '7', zip: 37181, city: 'Asche', state: 'Lower Saxony') }
end

Fabricator :power_giver_with_contracts, from: :power_giver do
  contracts   { [ Fabricate(:power_giver_contract)] }
end

Fabricator :metering_service_provider_with_contracting_party, from: :metering_service_provider do
  after_create do |organization|
    organization.update contracting_party: Fabricate(:contracting_party, legal_entity: 'company', organization: organization)
  end
end

# needed for groups fabricator
Fabricator :buzzn_metering, from: :metering_service_provider do
  name Organization::BUZZN_METERING
end

# needed for contracts fabricator
Fabricator :discovergy, from: :metering_service_provider do
  name 'Discovergy'
end

# needed for contracts fabricator
Fabricator :mysmartgrid, from: :metering_service_provider do
  name 'MySmartGrid'
end


Fabricator :buzzn_energy, from: :electricity_supplier do
  name Organization::BUZZN_ENERGY
end

Fabricator :dummy_energy, from: :electricity_supplier do
  name Organization::DUMMY_ENERGY
end

Fabricator :buzzn_reader, from: :register_operator do
  name Organization::BUZZN_READER
end
