Fabricator :electricity_supplier_contract do
  tariff                'Öko Strom XXL'
  status                'running'
  signing_user          { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
  customer_number       { sequence(:customer_number, 9261502) }
  contract_number       'xl245245235'
  terms                 true
  power_of_attorney     true
  confirm_pricing_model true
  commissioning         Date.new(2013,9,1)
  forecast_watt_hour_pa 1700
  price_cents           2995
  organization          { Fabricate(:electricity_supplier) }
  address               { Fabricate(:address) }
  bank_account          { Fabricate(:bank_account) }
end