# coding: utf-8
Fabricator :contract do
  status                   'running'
  customer_number          { sequence(:customer_number, 9261502) }
  contract_number          'xl245245235'
  signing_user             { "#{FFaker::Name.first_name} #{FFaker::Name.last_name}" }
  terms                    true
  power_of_attorney        true
  confirm_pricing_model    true
  retailer                 false
  price_cents_per_kwh      { rand * 10 }
  price_cents_per_month    { rand(100) }
  discount_cents_per_month { rand(10) }
  other_contract           { FFaker::Boolean.maybe }
  move_in                  { FFaker::Boolean.maybe }
  beginning                { FFaker::Time.date }
  authorization            { FFaker::Boolean.maybe }
  feedback                 { FFaker::Lorem.sentence }
  attention_by             { FFaker::Lorem.sentence }
  commissioning            Date.new(2013,9,1)
end


Fabricator :register_operator_contract, from: :contract do
  mode  'register_operator_contract'
end


Fabricator :servicing_contract, from: :contract do
  organization  { Organization.buzzn_metering }
  mode  'servicing_contract'
end




Fabricator :power_taker_contract, from: :contract do
  mode                  'power_taker_contract'
  forecast_watt_hour_pa 1700000
  price_cents           2995
  organization          { Fabricate(:electricity_supplier) }
  bank_account          { Fabricate(:bank_account) }
end

Fabricator :power_taker_contract_with_address, from: :power_taker_contract do
  address               { Fabricate(:address) }
end

Fabricator :power_giver_contract, from: :contract do
  mode                  'power_giver_contract'
  forecast_watt_hour_pa 1700000
  price_cents           3
  organization          { Fabricate(:electricity_supplier) }
  bank_account          { Fabricate(:bank_account) }
end

Fabricator :power_giver_contract_with_address, from: :power_giver_contract do
  address               { Fabricate(:address) }
end


Fabricator :mpoc_buzzn_metering, from: :register_operator_contract do
  organization  { Organization.buzzn_metering }
  username      'team@localpool.de'
  password      'Zebulon_4711'
end


Fabricator :mpoc_justus, from: :register_operator_contract do
  organization  { Organization.find('discovergy') }
  username      'justus@buzzn.net'
  password      'PPf93TcR'
end

Fabricator :mpoc_stefan, from: :register_operator_contract do
  organization  { Organization.find('discovergy') }
  username      'stefan@buzzn.net'
  password      '19200buzzn'
end

Fabricator :mpoc_karin, from: :register_operator_contract do
  organization  { Organization.find('discovergy') }
  username      'karin.smith@solfux.de'
  password      '19200buzzn'
end


Fabricator :mpoc_christian, from: :register_operator_contract do
  organization  { Organization.find('discovergy') }
  username      'christian@buzzn.net'
  password      'Roentgen11smartmeter'
end

Fabricator :mpoc_philipp, from: :register_operator_contract do
  organization  { Organization.find('discovergy') }
  username      'info@philipp-osswald.de'
  password      'Null8fünfzehn'
end

Fabricator :mpoc_thomas, from: :register_operator_contract do
  organization  { Organization.find('discovergy') }
  username      'thomas@buzzn.net'
  password      'DSivKK1980'
end

# thomas wohnung
Fabricator :mpoc_ferraris_0001_amperix, from: :register_operator_contract do
  organization  { Organization.find('mysmartgrid') }
  username      '6ed89edf81be48586afc19f9006feb8b'
  password      '1a875e34e291c28db95ecbda015ad433'
end

# wogeno oberländerstr bhkw
Fabricator :mpoc_ferraris_0002_amperix, from: :register_operator_contract do
  organization  { Organization.find('mysmartgrid') }
  username      '721bcb386c8a4dab2510d40a93a7bf66'
  password      '0b81f58c19135bc01420aa0120ae7693'
end
