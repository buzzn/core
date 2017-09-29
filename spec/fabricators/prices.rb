Fabricator :new_price, class_name: 'Price' do
  name                                { sequence(:price_name, 1) { |i| "Generic price #{i}" } }
  begin_date                          Date.parse("2016-01-01")
  energyprice_cents_per_kilowatt_hour 27.9
  baseprice_cents_per_month           300
  localpool                           { Fabricate(:new_localpool) }
end
