# coding: utf-8
Fabricator :contract do
  tariff                'localpool'
  status                'running'
  customer_number       { sequence(:customer_number, 9261502) }
  contract_number       'xl245245235'
  signing_user          { "#{FFaker::Name.first_name} #{FFaker::Name.last_name}" }
  terms                 true
  power_of_attorney     true
  confirm_pricing_model true
  commissioning         Date.new(2013,9,1)
end


Fabricator :metering_point_operator_contract, from: :contract do
  mode  'metering_point_operator_contract'
end


Fabricator :servicing_contract, from: :contract do
  organization  { Organization.find('buzzn-metering') }
  mode  'servicing_contract'
end




Fabricator :electricity_supplier_contract, from: :contract do
  mode                  'electricity_supplier_contract'
  tariff                'Öko Strom XXL'
  forecast_watt_hour_pa 1700000
  price_cents           2995
  organization          { Fabricate(:electricity_supplier) }
  bank_account          { Fabricate(:bank_account) }
end

Fabricator :electricity_supplier_contract_with_address, from: :electricity_supplier_contract do
  address               { Fabricate(:address) }
end


Fabricator :mpoc_buzzn_metering, from: :metering_point_operator_contract do
  organization  { Organization.find('buzzn-metering') }
  username      'team@localpool.de'
  password      'Zebulon_4711'
end


Fabricator :mpoc_justus, from: :metering_point_operator_contract do
  organization  { Organization.find('discovergy') }
  username      'justus@buzzn.net'
  password      'PPf93TcR'
end

Fabricator :mpoc_stefan, from: :metering_point_operator_contract do
  organization  { Organization.find('discovergy') }
  username      'stefan@buzzn.net'
  password      '19200buzzn'
end

Fabricator :mpoc_karin, from: :metering_point_operator_contract do
  organization  { Organization.find('discovergy') }
  username      'karin.smith@solfux.de'
  password      '19200buzzn'
end


Fabricator :mpoc_christian, from: :metering_point_operator_contract do
  organization  { Organization.find('discovergy') }
  username      'christian@buzzn.net'
  password      'Roentgen11smartmeter'
end

Fabricator :mpoc_philipp, from: :metering_point_operator_contract do
  organization  { Organization.find('discovergy') }
  username      'info@philipp-osswald.de'
  password      'Null8fünfzehn'
end

Fabricator :mpoc_thomas, from: :metering_point_operator_contract do
  organization  { Organization.find('discovergy') }
  username      'thomas@buzzn.net'
  password      'DSivKK1980'
end

# thomas wohnung
Fabricator :mpoc_ferraris_0001_amperix, from: :metering_point_operator_contract do
  organization  { Organization.find('mysmartgrid') }
  username      '6ed89edf81be48586afc19f9006feb8b'
  password      '1a875e34e291c28db95ecbda015ad433'
end

# wogeno oberländerstr bhkw
Fabricator :mpoc_ferraris_0002_amperix, from: :metering_point_operator_contract do
  organization  { Organization.find('mysmartgrid') }
  username      '721bcb386c8a4dab2510d40a93a7bf66'
  password      '0b81f58c19135bc01420aa0120ae7693'
end












