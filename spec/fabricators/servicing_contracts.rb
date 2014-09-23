Fabricator :servicing_contract do
  tariff                'localpool'
  status                'running'
  signing_user          { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
  terms                 true
  power_of_attorney     true
  confirm_pricing_model true
  commissioning         Date.new(2013,9,1)
end