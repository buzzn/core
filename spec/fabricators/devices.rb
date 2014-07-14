Fabricator :device do
  shop_link                     'http://www.amazon.com'
end

Fabricator :bhkw_justus, from: :device do
  image                         { File.new(Rails.root.join('db', 'seed_assets', 'devices', 'ecopower1.jpg')) }
  law                           ''
  mode                          'out'
  manufacturer                  'Honda'
  manufacturer_product_number   'EcoPower 1.0'
  generator_type                'chp'
  primary_energy                'gas'
  watt_peak                     1*1000
  commissioning                 Date.new(2012,10,1)
end

Fabricator :dach_pv_justus, from: :device do
  law                           'EEG'
  mode                          'out'
  manufacturer                  'solarwatt'
  manufacturer_product_number   'PV 8,51'
  generator_type                'pv'
  watt_peak                     8.51*1000
  commissioning                 Date.new(2012,3,31)
end

Fabricator :carport_pv_justus, from: :device do
  law                           'EEG'
  mode                          'out'
  manufacturer                  'solarwatt'
  manufacturer_product_number   'PV 5,3'
  generator_type                'pv'
  watt_peak                     5.3*1000
  commissioning                 Date.new(2012,1,1)
end


Fabricator :pv_karin, from: :device do
  image                         { File.new(Rails.root.join('db', 'seed_assets', 'devices', 'pv_karin.jpg')) }

  law                           'EEG'
  mode                          'out'
  manufacturer                  'Solarex'
  manufacturer_product_number   'MX-64'
  generator_type                'pv'
  watt_peak                     2.16*1000
  commissioning                 Date.new(2002,11,1)
end
