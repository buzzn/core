Fabricator :new_tariff, class_name: "Contract::Tariff" do
  name                      { sequence(:tariff_name) { |i| "Generic Tariff #{i + 1}" } }
  begin_date                Date.parse("2000-01-01")
  energyprice_cents_per_kwh 42
  baseprice_cents_per_month 300
  contracts                 { Fabricate(:new_contract) }
end
