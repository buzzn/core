Fabricator :metering_point do
  address_addition  'Keller'
  uid               'DE0010688251510000000000002677114'
  register          { Fabricate(:meter).registers.first }
  contract          { Fabricate(:contract) }
end





Fabricator :mp_z1, from: :metering_point do
  address_addition  'Übergabe'
  uid               'DE0010688251510000000000002677114'

  register {
    Fabricate( :meter,
                manufacturer_name:           'Elster',
                manufacturer_product_number: 'AS 1440',
                manufacturer_device_number:   '03353984',
                ).registers.first
  }

end

Fabricator :mp_z2, from: :metering_point do
  address_addition  'Dach'

  register {
     Fabricate(:meter,
                manufacturer_name:           'Kamstrup',
                manufacturer_product_number: '382J',
                manufacturer_device_number:   '15028648',
                ).registers.first
  }
  devices           {[Fabricate(:dach_pv_justus)]}
end



Fabricator :mp_z3, from: :metering_point do
  address_addition  'Carport'
  register {
    Fabricate(:meter,
              manufacturer_name:            'Kamstrup',
              manufacturer_product_number:  '382J',
              manufacturer_device_number:    '15028641',
              ).registers.first
  }
  devices           {[Fabricate(:carport_pv_justus)]}
end


Fabricator :mp_z4, from: :metering_point do
  address_addition  'Keller'
  register {
    Fabricate(:meter,
              manufacturer_name:            'Kamstrup',
              manufacturer_product_number:  '382J',
              manufacturer_device_number:   '15028644',
              ).registers.first
  }
  devices           {[Fabricate(:bhkw_justus)]}
end


Fabricator :mp_z5, from: :metering_point do
  address_addition  'Keller'
  register {
    Fabricate(:easymeter_1024000034).registers.first
  }
  metering_service_provider_contract {Fabricate(:mspc_justus)}
end

