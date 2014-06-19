Fabricator :metering_point do
  address_addition  'Keller'
  mode              'down'
  meter             { Fabricate(:meter) }
  contract          { Fabricate(:contract) }
end





Fabricator :mp_z1, from: :metering_point do
  address_addition  'Übergabe'
  mode              'up_down'
  uid               'DE0010688251510000000000002677114'
  meter             { Fabricate(:meter,
                                manufacturer_name:           'Elster',
                                manufacturer_product_number: 'AS 1440',
                                manufacturer_device_number:   '03353984',
                                virtual:                     false
                                )}
end

Fabricator :mp_z2, from: :metering_point do
  address_addition  'Dach'
  mode              'up'
  meter             { Fabricate(:meter,
                                manufacturer_name:           'Kamstrup',
                                manufacturer_product_number: '382J',
                                manufacturer_device_number:   '15028648',
                                virtual:                     false
                                )}
  devices           {[Fabricate(:dach_pv_justus)]}
end



Fabricator :mp_z3, from: :metering_point do
  address_addition  'Carport'
  mode              'up'
  meter             { Fabricate(:meter,
                                manufacturer_name:            'Kamstrup',
                                manufacturer_product_number:  '382J',
                                manufacturer_device_number:    '15028641',
                                virtual:                      false
                                )}
  devices           {[Fabricate(:carport_pv_justus)]}
end


Fabricator :mp_z4, from: :metering_point do
  address_addition  'Keller'
  mode              'up'
  meter             { Fabricate(:meter,
                                manufacturer_name:            'Kamstrup',
                                manufacturer_product_number:  '382J',
                                manufacturer_device_number:    '15028644',
                                virtual:                      false
                                )}
  devices           {[Fabricate(:bhkw_justus)]}
end