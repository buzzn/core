Fabricator :device do
  mode                          'in'
  manufacturer_name             { FFaker::Product.brand }
  manufacturer_product_name     { FFaker::Product.product_name }
  category                      'Elektroauto'
  watt_peak                     49000
  commissioning                 { FFaker::Time.date }
  shop_link                     'http://www.amazon.com'
end



Fabricator :auto_justus, from: :device do
  mode                          'in'
  manufacturer_name             'Mitsubishi'
  manufacturer_product_name     'i-MiEV'
  category                      'Elektroauto'
  watt_peak                     49000
  commissioning                 Date.new(2012,10,1)
  image { File.new(Rails.root.join('db', 'seed_assets', 'devices', 'justus', 'auto.jpg' )) }
end


Fabricator :bhkw_justus, from: :device do
  law                           'kwkg'
  mode                          'out'
  manufacturer_name             'Honda'
  manufacturer_product_name     'EcoPower 1.0'
  category                      'Blockheizkraftwerk'
  primary_energy                'gas'
  watt_peak                     1000
  commissioning                 Date.new(2012,10,1)
  image { File.new(Rails.root.join('db', 'seed_assets', 'devices', 'justus', 'bhkw.jpg' )) }
  readable    'world'
end

Fabricator :dach_pv_justus, from: :device do
  law                           'eeg'
  mode                          'out'
  manufacturer_name             'solarwatt'
  manufacturer_product_name     'PV 8,51'
  category                      'Photovoltaikanlage'
  primary_energy                'sun'
  watt_peak                     8510
  commissioning                 Date.new(2012,3,31)
  image { File.new(Rails.root.join('db', 'seed_assets', 'devices', 'justus', 'pv.jpg' )) }
  readable    'world'
end

Fabricator :carport_pv_justus, from: :device do
  law                           'eeg'
  mode                          'out'
  manufacturer_name             'solarwatt'
  manufacturer_product_name     'PV 5,3'
  category                      'Photovoltaikanlage'
  primary_energy                'sun'
  watt_peak                     5300
  commissioning                 Date.new(2012,1,1)
  image { File.new(Rails.root.join('db', 'seed_assets', 'devices', 'justus', 'carport-pv.jpg' )) }
  readable    'world'
end


Fabricator :pv_karin, from: :device do
  law                           'eeg'
  mode                          'out'
  manufacturer_name             'Solarex'
  manufacturer_product_name     'MX-64'
  category                      'Photovoltaikanlage'
  primary_energy                'sun'
  watt_peak                     2160
  commissioning                 Date.new(2002,11,1)
  image { File.new(Rails.root.join('db', 'seed_assets', 'devices', 'karin', 'pv.jpg' )) }
end


Fabricator :bhkw_stefan, from: :device do
  law                           'kwkg'
  mode                          'out'
  manufacturer_name             'Senertec'
  manufacturer_product_name     'Dachs'
  category                      'Blockheizkraftwerk'
  primary_energy                'gas'
  watt_peak                     5500
  commissioning                 Date.new(1995,11,1)
  image { File.new(Rails.root.join('db', 'seed_assets', 'devices', 'stefan', 'bhkw.jpg' )) }
end



Fabricator :hof_butenland_wind, from: :device do
  law                           'eeg'
  mode                          'out'
  manufacturer_name             'Enercon'
  manufacturer_product_name     '16'
  category                      'Windkraftanlage'
  primary_energy                'wind'
  watt_peak                     55000
  commissioning                 Date.new(1989,12,1)
  image { File.new(Rails.root.join('db', 'seed_assets', 'devices', 'butenland', 'wind.jpg' )) }
  readable    'world'
end





Fabricator :gocycle, from: :device do
  mode                          'in'
  manufacturer_name             'Gocycle'
  manufacturer_product_name     'GR2'
  category                      'Pedelec'
  watt_peak                     250
  commissioning                 Date.new(2014,6,1)
  image { File.new(Rails.root.join('db', 'seed_assets', 'devices', 'felix', 'gocycle.jpg' )) }
  readable    'world'
end




