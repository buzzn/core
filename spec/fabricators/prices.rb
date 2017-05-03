# coding: utf-8
Fabricator :price do
  name                                { FFaker::Company.name }
  begin_date                          { Date.new(2017, 1, 1)}
  energyprice_cents_per_kilowatt_hour { 22.556 } # assume all money-data is without taxes!
  baseprice_cents_per_month           { 200 }
  localpool                           { Fabricate(:localpool) }
end

Fabricator :price_sulz, from: :price do
  name                                { 'Standard' }
  begin_date                          { Date.new(2016, 8, 4)}
  energyprice_cents_per_kilowatt_hour { 23.8 } # assume all money-data is without taxes!
  baseprice_cents_per_month           { 500 }
end