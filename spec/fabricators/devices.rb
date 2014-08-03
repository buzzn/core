Fabricator :device do
  shop_link                     'http://www.amazon.com'
end

Fabricator :bhkw_justus, from: :device do
  image                         { File.new(Rails.root.join('db', 'seed_assets', 'devices', 'ecopower1.jpg')) }
  law                           'kwkg'
  mode                          'out'
  manufacturer_name             'Honda'
  manufacturer_product_name     'EcoPower 1.0'
  generator_type                'chp'
  primary_energy                'gas'
  watt_peak                     1*1000
  commissioning                 Date.new(2012,10,1)
end

Fabricator :dach_pv_justus, from: :device do
  law                           'eeg'
  mode                          'out'
  manufacturer_name             'solarwatt'
  manufacturer_product_name     'PV 8,51'
  generator_type                'pv'
  watt_peak                     8.51*1000
  commissioning                 Date.new(2012,3,31)
end

Fabricator :carport_pv_justus, from: :device do
  law                           'eeg'
  mode                          'out'
  manufacturer_name             'solarwatt'
  manufacturer_product_name     'PV 5,3'
  generator_type                'pv'
  watt_peak                     5.3*1000
  commissioning                 Date.new(2012,1,1)
end


Fabricator :pv_karin, from: :device do
  image                         { File.new(Rails.root.join('db', 'seed_assets', 'devices', 'pv_karin.jpg')) }
  law                           'eeg'
  mode                          'out'
  manufacturer_name             'Solarex'
  manufacturer_product_name     'MX-64'
  generator_type                'pv'
  watt_peak                     2.16*1000
  commissioning                 Date.new(2002,11,1)
end


Fabricator :bhkw_stefan, from: :device do
  image                         { File.new(Rails.root.join('db', 'seed_assets', 'devices', 'bhkw_stefan.jpg')) }
  law                           'kwkg'
  mode                          'out'
  manufacturer_name             'Senertec'
  manufacturer_product_name     'Dachs'
  generator_type                'chp'
  primary_energy                'gas'
  watt_peak                     5.5*1000
  commissioning                 Date.new(1995,11,1)
end



Fabricator :hof_butenland_wind, from: :device do
  image                         { File.new(Rails.root.join('db', 'seed_assets', 'devices', 'hof_butenland_wind.jpg')) }
  law                           'eeg'
  mode                          'out'
  manufacturer_name             'Enercon'
  manufacturer_product_name     '16'
  generator_type                'wind'
  primary_energy                'wind'
  watt_peak                     55*1000
  commissioning                 Date.new(1989,12,1)
end



