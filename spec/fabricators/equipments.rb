Fabricator :equipment, class_name: Meter::Equipment do
  manufacturer_name                 'Easymeter'
  manufacturer_product_name         'Some Product'
  manufacturer_product_serialnumber '12345678'
  created_at                        { (rand*10).days.ago }
  device_kind                       'converter'
  device_type                       'other'
  ownership                         { Meter::Equipment::BUZZN_SYSTEMS }
  build                             { (rand*11).days.ago }
  calibrated_till                   { 5.years.from_now }
  converter_constant                1
end
