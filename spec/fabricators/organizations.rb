# coding: utf-8
Fabricator :organization do
  name        { FFaker::Company.name }
  phone       { FFaker::PhoneNumber.phone_number }
  fax         { FFaker::PhoneNumber.phone_number }
  email       { FFaker::Internet.email }
  description { FFaker::Company.catch_phrase }
  website     { "http://www.#{FFaker::Internet.domain_name}" }
end


Fabricator :other_organization, from: :organization do
  mode 'other'
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
  after_create do |organization|
    Fabricate(:power_giver_contract, customer: organization.contracting_party)
  end

end

# needed for groups fabricator - legacy naming
Fabricator :buzzn_metering, from: :metering_service_provider do
  name Organization::BUZZN_SYSTEMS
end


Fabricator :discovergy, from: :metering_service_provider do
  name Organization::DISCOVERGY
end

Fabricator :mysmartgrid, from: :metering_service_provider do
  name Organization::MYSMARTGRID
end

Fabricator :buzzn_systems, from: :metering_service_provider do
  name Organization::BUZZN_SYSTEMS
end

Fabricator :buzzn_energy, from: :electricity_supplier do
  name Organization::BUZZN_ENERGY
end

Fabricator :dummy_energy, from: :electricity_supplier do
  name Organization::DUMMY_ENERGY
end

Fabricator :dummy, from: :other_organization do
  name Organization::DUMMY
end

# TODO what is this for ?
Fabricator :buzzn_reader, from: :register_operator do
  name Organization::BUZZN_READER
end
