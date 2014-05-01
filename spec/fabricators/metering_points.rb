Fabricator :metering_point do
  address_addition  'Keller'
  uid               ''
  mode              'down_meter'
  meter             { Fabricate(:meter) }
end





Fabricator :mp_z1, from: :metering_point do
  address_addition  'Übergabe'
  mode              'up_down_metering'
  uid               'DE0010688251510000000000002677114'
  meter             { Fabricate(:meter,
                                manufacturer_name:           'Elster',
                                manufacturer_product_number: 'AS 1440',
                                manufacturer_meter_number:   '03353984',
                                virtual:                     false
                                )}
end

Fabricator :mp_z2, from: :metering_point do
  address_addition  'Dach'
  mode              'up_metering'
  uid               ''
  meter             { Fabricate(:meter,
                                manufacturer_name:           'Kamstrup',
                                manufacturer_product_number: '382J',
                                manufacturer_meter_number:   '15028648',
                                virtual:                     false
                                )}
  devices           {[Fabricate(:dach_pv_justus)]}
end

Fabricator :mp_z3, from: :metering_point do
  address_addition  'Carport'
  mode              'diff_metering'
  uid               ''
  meter             { Fabricate(:meter,
                                manufacturer_name:            'Kamstrup',
                                manufacturer_product_number:  '382J',
                                manufacturer_meter_number:    '15028646',
                                virtual:                      false
                                )}
end

Fabricator :mp_z4, from: :metering_point do
  address_addition  'Carport'
  mode              'up_metering'
  uid               ''
  meter             { Fabricate(:meter,
                                manufacturer_name:            'Kamstrup',
                                manufacturer_product_number:  '382J',
                                manufacturer_meter_number:    '15028641',
                                virtual:                      false
                                )}
  devices           {[Fabricate(:carport_pv_justus)]}
end

Fabricator :mp_z5, from: :metering_point do
  address_addition  'Garten'
  mode              'up_metering'
  uid               ''
  meter             { Fabricate(:meter,
                                manufacturer_name:            'Kamstrup',
                                manufacturer_product_number:  '382J',
                                manufacturer_meter_number:    '15028650',
                                virtual:                      false
                                )}
end

Fabricator :mp_z6, from: :metering_point do
  address_addition  'Garten'
  mode              'diff_metering'
  uid               ''
  meter             { Fabricate(:meter,
                                manufacturer_name:            'Kamstrup',
                                manufacturer_product_number:  '382J',
                                manufacturer_meter_number:    '15028649',
                                virtual:                      false
                                )}
end

Fabricator :mp_z7, from: :metering_point do
  address_addition  'Keller'
  mode              'up_metering'
  uid               ''
  meter             { Fabricate(:meter,
                                manufacturer_name:            'Elster',
                                manufacturer_product_number:  'AS 1440',
                                manufacturer_meter_number:    '03381969',
                                virtual:                      false
                                )}
end

Fabricator :mp_z8, from: :metering_point do
  address_addition  'Keller'
  mode              'up_metering'
  uid               ''
  meter             { Fabricate(:meter,
                                manufacturer_name:            'Kamstrup',
                                manufacturer_product_number:  '382J',
                                manufacturer_meter_number:    '15028644',
                                virtual:                      false
                                )}
  devices           {[Fabricate(:bhkw_justus)]}
end