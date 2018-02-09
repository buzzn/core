Fabricator :organization do
  name        { FFaker::Company.name }
  phone       { FFaker::PhoneNumber.phone_number }
  fax         { FFaker::PhoneNumber.phone_number }
  email       { FFaker::Internet.email }
  description { FFaker::Company.catch_phrase }
  website     { "http://www.#{FFaker::Internet.domain_name}" }
end


Fabricator :other_organization, from: :organization do
end

Fabricator :distribution_system_operator, from: :organization do
end

Fabricator :power_giver, from: :organization do
end

Fabricator :electricity_supplier, from: :organization do
end

Fabricator :metering_service_provider, from: :organization do
end

Fabricator :metering_point_operator, from: :organization do
end

Fabricator :transmission_system_operator, from: :organization do
end

Fabricator :power_giver_with_contracts, from: :power_giver do
  after_create do |organization|
    Fabricate(:power_giver_contract, customer: organization)
  end
end

# This fabricator should not be used any more, use the hell & warm organization loaded with setup
Fabricator :hell_und_warm_deprecated, from: :other_organization do
  name        'hell & warm Forstenried GmbH (deprecated)'
  phone       '089-89057180'
  email       't.brumbauer@wogeno.de'
  description 'Betreiber des Localpools Forstenried'
  after_create do |o|
    o.update(address: Fabricate(:address, street: 'Aberlestraße 16', zip: '81371', city: 'München'))
  end
end

# needed for groups fabricator - legacy naming
Fabricator :buzzn_metering, from: :metering_point_operator do
  name 'buzzn systems UG'
end

Fabricator :discovergy, from: :metering_point_operator do
  name 'Discovergy'
end

Fabricator :mysmartgrid, from: :metering_point_operator do
  name 'MySmartGrid'
end

Fabricator :buzzn, from: :electricity_supplier do
  name 'buzzn GmbH'
end

Fabricator :germany, from: :electricity_supplier do
  name 'Germany Energy Mix'
end

Fabricator :gemeindewerke_peissenberg, from: :electricity_supplier do
  name 'Gemeindewerke Peißenberg'
end
