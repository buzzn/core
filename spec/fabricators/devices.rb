Fabricator :device do
  shop_link                     'http://www.amazon.com'
end

Fabricator :bhkw_justus, from: :device do
  assets                         { [
                                    Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'assets', 'ecopower1.jpg')), description: 'ecopower')
                                    ] }
  law                           'kwkg'
  mode                          'out'
  manufacturer_name             'Honda'
  manufacturer_product_name     'EcoPower 1.0'
  device_type                   'chp'
  primary_energy                'gas'
  watt_peak                     1000
  commissioning                 Date.new(2012,10,1)
end

Fabricator :dach_pv_justus, from: :device do
  law                           'eeg'
  mode                          'out'
  manufacturer_name             'solarwatt'
  manufacturer_product_name     'PV 8,51'
  device_type                   'pv'
  primary_energy                'sun'
  watt_peak                     8510
  commissioning                 Date.new(2012,3,31)
end

Fabricator :carport_pv_justus, from: :device do
  law                           'eeg'
  mode                          'out'
  manufacturer_name             'solarwatt'
  manufacturer_product_name     'PV 5,3'
  device_type                   'pv'
  primary_energy                'sun'
  watt_peak                     5300
  commissioning                 Date.new(2012,1,1)
end


Fabricator :pv_karin, from: :device do
  assets                         { [
                                    Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'assets', 'pv_karin.jpg')))
                                    ] }
  law                           'eeg'
  mode                          'out'
  manufacturer_name             'Solarex'
  manufacturer_product_name     'MX-64'
  device_type                   'pv'
  primary_energy                'sun'
  watt_peak                     2160
  commissioning                 Date.new(2002,11,1)
end


Fabricator :bhkw_stefan, from: :device do
  assets                         { [
                                    Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'assets', 'bhkw_stefan.jpg')))
                                    ] }
  law                           'kwkg'
  mode                          'out'
  manufacturer_name             'Senertec'
  manufacturer_product_name     'Dachs'
  device_type                   'chp'
  primary_energy                'gas'
  watt_peak                     5500
  commissioning                 Date.new(1995,11,1)
end



Fabricator :hof_butenland_wind, from: :device do
  assets                         { [
                                    Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'assets', 'hof_butenland_wind.jpg')))
                                    ] }
  law                           'eeg'
  mode                          'out'
  manufacturer_name             'Enercon'
  manufacturer_product_name     '16'
  device_type                   'wind'
  primary_energy                'wind'
  watt_peak                     55000
  commissioning                 Date.new(1989,12,1)
end





Fabricator :gocycle, from: :device do
  assets                         { [
                                    Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'assets', 'gocycle1.jpg')), description: 'Ich freue mich wie ein Schneekönig.'),
                                    Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'assets', 'gocycle2.jpg')), description: 'Mit der App kann ich das Bike tunen.')
                                    ] }
  mode                          'in'
  manufacturer_name             'Gocycle'
  manufacturer_product_name     'GR2'
  device_type                   'E-Bike'
  watt_peak                     250
  commissioning                 Date.new(2014,6,1)
end




